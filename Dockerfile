FROM remotepixel/amazonlinux-gdal:2.4.0

RUN pip3 install cython numpy --no-binary numpy

RUN pip3 install rasterio --no-binary rasterio
RUN pip3 install rio-cogeo

RUN yum install -y jq wget

RUN mkdir /prod
RUN mkdir /cog
RUN mkdir /raw

# Get RAW data
RUN cd /raw \
  && wget https://s3-us-west-2.amazonaws.com/remotepixel-pub/ARD/LC08_CU_028004_20171002_20171018_C01_V01_SRB2.tif \
  && wget https://s3-us-west-2.amazonaws.com/remotepixel-pub/ARD/LC08_CU_028004_20171002_20171018_C01_V01_SRB3.tif \
  && wget https://s3-us-west-2.amazonaws.com/remotepixel-pub/ARD/LC08_CU_028004_20171002_20171018_C01_V01_SRB4.tif

# Create products
RUN rio stack /raw/LC08_CU_028004_20171002_20171018_C01_V01_SRB4.tif /raw/LC08_CU_028004_20171002_20171018_C01_V01_SRB3.tif /raw/LC08_CU_028004_20171002_20171018_C01_V01_SRB2.tif -o /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Int16.tif --overwrite
RUN gdal_translate -ot Byte -scale -2000 16000 1 255 -a_nodata -9999 /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Int16.tif /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Byte.tif
RUN gdal_translate -ot Int32 -a_nodata -9999 /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Int16.tif /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Int32.tif
RUN gdal_translate -ot UInt16 -scale -2000 16000 1 18000 -a_nodata -9999 /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Int16.tif /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Uint16.tif
RUN gdal_translate -ot UInt32 -scale -2000 16000 1 18000 -a_nodata -9999 /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Int16.tif /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Uint32.tif
RUN gdal_translate -ot Float32 -a_nodata -9999 /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Int16.tif /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Float32.tif
RUN gdal_translate -ot Float64 -a_nodata -9999 /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Int16.tif /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Float64.tif
RUN rm -rf /raw

# Create Cogs
RUN rio cogeo /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Int16.tif /cog/3B_Int16_cogeo.tif --cog-profile deflate
RUN rio cogeo /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Int16.tif /cog/1B_Int16_cogeo.tif --cog-profile deflate --bidx 1
RUN rio cogeo /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Byte.tif /cog/3B_Byte_cogeo.tif --cog-profile deflate
RUN rio cogeo /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Byte.tif /cog/1B_Byte_cogeo.tif --cog-profile deflate --bidx 1
RUN rio cogeo /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Uint16.tif /cog/3B_Uint16_cogeo.tif --cog-profile deflate
RUN rio cogeo /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Uint16.tif /cog/1B_Uint16_cogeo.tif --cog-profile deflate --bidx 1
RUN rio cogeo /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Uint32.tif /cog/3B_Uint32_cogeo.tif --cog-profile deflate
RUN rio cogeo /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Uint32.tif /cog/1B_Uint32_cogeo.tif --cog-profile deflate --bidx 1
RUN rio cogeo /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Int32.tif /cog/3B_Int32_cogeo.tif --cog-profile deflate
RUN rio cogeo /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Int32.tif /cog/1B_Int32_cogeo.tif --cog-profile deflate --bidx 1
RUN rio cogeo /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Float32.tif /cog/3B_Float32_cogeo.tif --cog-profile deflate
RUN rio cogeo /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Float32.tif /cog/1B_Float32_cogeo.tif --cog-profile deflate --bidx 1
RUN rio cogeo /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Float64.tif /cog/3B_Float64_cogeo.tif --cog-profile deflate
RUN rio cogeo /prod/LC08_CU_028004_20171002_20171018_C01_V01_RGB432_Float64.tif /cog/1B_Float64_cogeo.tif --cog-profile deflate --bidx 1
RUN rm -rf /prod
