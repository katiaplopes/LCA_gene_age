#!/usr/bin/python
import sys
from xml.dom import minidom
import MySQLdb
import MySQLdb.cursors
import urllib2
import urllib
import argparse
__author__ = 'ricardo'
 
parser = argparse.ArgumentParser(description='This is a demo script')
parser.add_argument('-t','--taxid', help='Organism taxonomy id',required=True)
parser.add_argument('-u','--genelist',help='File of a list of gene ids, one per row. Use the full path to file', required=True)
parser.add_argument('-i','--idtype',help='Ids type, uniprot or ensembl', required=True)
args = parser.parse_args()
 
## show values ##
print ("TaxId: %s" % args.taxid )
print ("Genes list file: %s" % args.genelist )
print ("Ids: %s" % args.idtype )

idtype = args.idtype
querytaxid = args.taxid

url = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi'
params = urllib.urlencode({
  'db': 'taxonomy',
  'id': str(querytaxid)
})
response = urllib2.urlopen(url, params).read()

xmldoc = minidom.parseString(response)
itemlist = xmldoc.getElementsByTagName('Lineage')
lin = itemlist[0].firstChild.nodeValue
itemlist = xmldoc.getElementsByTagName('ScientificName')
spc = itemlist[0].firstChild.nodeValue
lineage = lin.split("; ")
lineage.append(spc)
lineage.insert(0,'root')

rank_count = [0]*len(lineage)

db = MySQLdb.connect("127.0.0.1","biodados","sacizeir0","OMA",local_infile = 1)

cursor0 = db.cursor(MySQLdb.cursors.Cursor)
cursor0.execute("CREATE TEMPORARY TABLE genelist(ids varchar(20), index(ids))")

cursor00 = db.cursor(MySQLdb.cursors.Cursor)
cursor00.execute("load data local infile '" + args.genelist + "' into table genelist")

cursor000 = db.cursor(MySQLdb.cursors.Cursor)
if (idtype == 'uniprot'):
	cursor000.execute("SELECT count(distinct a.uniprot) FROM oma_uniprot a INNER JOIN genelist b ON a.uniprot=b.ids")
	print ("Number of distinct uniprots into database: " + str(cursor000.fetchone()[0]))
	cursor000.execute("SELECT count(distinct a.omaid) FROM oma_uniprot a INNER JOIN genelist b ON a.uniprot=b.ids")
	print ("Number of distinct omaids into database: " + str(cursor000.fetchone()[0]))
	cursor000.execute("SELECT count(distinct a.group_number) FROM oma_groups_omacode_taxid a INNER JOIN oma_uniprot b ON a.omaid=b.omaid INNER JOIN genelist c ON b.uniprot=c.ids")
	print ("Number of distinct groups into database: " + str(cursor000.fetchone()[0]))
	cursor000.execute("SELECT count(distinct b.uniprot) FROM oma_groups_omacode_taxid a INNER JOIN oma_uniprot b ON a.omaid=b.omaid INNER JOIN genelist c ON b.uniprot=c.ids")
	print ("Number of distinct uniprots mapped into groups: " + str(cursor000.fetchone()[0]))
	cursor1 = db.cursor(MySQLdb.cursors.Cursor)
	cursor1.execute("SELECT distinct a.group_number FROM oma_groups_omacode_taxid a INNER JOIN oma_uniprot b ON a.omaid=b.omaid INNER JOIN genelist c ON b.uniprot=c.ids")
	groupsidlist = [item[0] for item in cursor1.fetchall()]
elif (idtype == 'ensembl'):
	cursor000.execute("SELECT count(distinct a.ensembl) FROM oma_ensembl a INNER JOIN genelist b ON a.ensembl=b.ids")
	print ("Number of distinct ensembls into database: " + str(cursor000.fetchone()[0]))
	cursor000.execute("SELECT count(distinct a.omaid) FROM oma_ensembl a INNER JOIN genelist b ON a.ensembl=b.ids")
	print ("Number of distinct omaids into database: " + str(cursor000.fetchone()[0]))
	cursor000.execute("SELECT count(distinct a.group_number) FROM oma_groups_omacode_taxid a INNER JOIN oma_ensembl b ON a.omaid=b.omaid INNER JOIN genelist c ON b.ensembl=c.ids")
	print ("Number of distinct groups into database: " + str(cursor000.fetchone()[0]))
	cursor000.execute("SELECT count(distinct b.ensembl) FROM oma_groups_omacode_taxid a INNER JOIN oma_ensembl b ON a.omaid=b.omaid INNER JOIN genelist c ON b.ensembl=c.ids")
	print ("Number of distinct ensembls mapped into groups: " + str(cursor000.fetchone()[0]))
	cursor1 = db.cursor(MySQLdb.cursors.Cursor)
	cursor1.execute("SELECT distinct a.group_number FROM oma_groups_omacode_taxid a INNER JOIN oma_ensembl b ON a.omaid=b.omaid INNER JOIN genelist c ON b.ensembl=c.ids")
	groupsidlist = [item[0] for item in cursor1.fetchall()]
else:
	print ("Invalid id type")
	sys.exit()

cursor2 = db.cursor(MySQLdb.cursors.Cursor)
cursor2.execute("CREATE TEMPORARY TABLE maplist(agroup int, alca varchar(25), arank int, index(agroup), index(alca), index(arank))")

cursor3 = db.cursor(MySQLdb.cursors.Cursor)

cursor4 = db.cursor(MySQLdb.cursors.Cursor)

for (group) in groupsidlist:
	cursor3.execute("SELECT lca FROM omagroup_lca where group_number=" + str(group))
	lca = cursor3.fetchone()[0]
	idx = lineage.index(lca)
	cursor4.execute("INSERT INTO maplist VALUES (" + str(group) + ",'" + lca + "'," + str(idx) + ")")
	rank_count[idx] = rank_count[idx] + 1

print [str(item) for item in lineage]
print rank_count

cursor5 = db.cursor(MySQLdb.cursors.Cursor)
if (idtype == 'uniprot'):
	cursor5.execute("SELECT t.ids,t.alca,t.arank AS rank,count(t.group_number) AS grupos FROM (SELECT distinct c.ids,d.alca,d.arank,a.group_number FROM oma_groups_omacode_taxid a INNER JOIN oma_uniprot b ON a.omaid=b.omaid INNER JOIN genelist c ON b.uniprot=c.ids INNER JOIN maplist d ON a.group_number=d.agroup ORDER BY d.arank) t GROUP BY t.ids ORDER BY grupos")
	f = open(args.genelist + '.oma.list', 'w')
	for item in cursor5.fetchall():
		f.write(item[0] + '\t' + item[1] + '\t' + str(item[2]) + '\n')
	f.close()
elif (idtype == 'ensembl'):
	cursor5.execute("SELECT t.ids,t.alca,t.arank AS rank,count(t.group_number) AS grupos FROM (SELECT distinct c.ids,d.alca,d.arank,a.group_number FROM oma_groups_omacode_taxid a INNER JOIN oma_ensembl b ON a.omaid=b.omaid INNER JOIN genelist c ON b.ensembl=c.ids INNER JOIN maplist d ON a.group_number=d.agroup ORDER BY d.arank) t GROUP BY t.ids ORDER BY grupos")
	f = open(args.genelist + '.oma.list', 'w')
	for item in cursor5.fetchall():
		f.write(item[0] + '\t' + item[1] + '\t' + str(item[2]) + '\n')
	f.close()
else:
	print ("Invalid id type")
	sys.exit()

db.close()
