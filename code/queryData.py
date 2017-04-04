from pyspark.sql import SparkSession

spark = SparkSession.builder \
  .master("local") \
  .appName("ERA") \
  .getOrCreate()

df = spark.read \
  .format('com.databricks.spark.avro') \
  .load('/output/era.avro')
df.registerTempTable("era")
spark.sql("""SELECT playerID, ERA
  FROM era
  WHERE yearID = '2006'
    AND ERA <> 0.0
  ORDER BY ERA ASC
  LIMIT 10
""").show()

spark.sql("""SELECT playerID, IPOuts
  FROM era
  WHERE yearID = '2006'
  ORDER BY IPOUTS DESC
  LIMIT 1
""").show()
