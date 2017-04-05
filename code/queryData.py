from pyspark.sql import SparkSession

spark = SparkSession.builder \
  .master("local") \
  .appName("ERA") \
  .getOrCreate()

df = spark.read \
  .format('com.databricks.spark.avro') \
  .load('/output/era.avro')
df.registerTempTable("era")

# Please note that I'm excluding any player records
# with a 0.0 ERA. Apparently that means they never
# pitched during the season? Or just pitched really
# (well|badly) but only for a single game?
#
# Anyway, someone who knows baseball told me that
# it was unlikely for a pitcher to have a season
# ERA of 0, so we'll just ignore those records
# for the purpose of this exercise.
results = spark.sql("""SELECT playerID, ERA
  FROM era
  WHERE yearID = '2006'
    AND ERA <> 0.0
  ORDER BY ERA ASC
  LIMIT 10
""").write \
  .csv("/output/lowestERA", mode = "overwrite", header = True)

# We divide by 3 here since the data dictionary
# accompanying the source data specifies that
# IPOuts = innings pitched X 3
spark.sql("""SELECT playerID, IPOuts / 3
  FROM era
  WHERE yearID = '2006'
  ORDER BY IPOUTS DESC
  LIMIT 1
""").write \
  .csv("/output/mostInnings", mode = "overwrite", header = True)
