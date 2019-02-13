#!/usr/bin/env bash


function run() {
    [ "$#" -lt 1 ] && echo "Usage: main <rasterio version>" && exit 1
    version=$1
    pip install rasterio==${version} rio-tiler~=1.0 --no-binary rasterio
    python -c 'import rasterio; print(rasterio.__version__)'

    # 1Band
    echo "------"
    echo "1 band dataset"

    for DATATYPE in "Byte" "Int16" "Int32" "Uint16" "Uint32" "Float32" "Float64"
    do
      echo
      echo $DATATYPE
      time python test.py /cog/1B_${DATATYPE}_cogeo.tif
    done

    echo "------"
    echo "3 bands dataset"
    # 3Bands
    for DATATYPE in "Byte" "Int16" "Int32" "Uint16" "Uint32" "Float32" "Float64"
    do
      echo
      echo $DATATYPE
      time python test.py /cog/3B_${DATATYPE}_cogeo.tif
    done

    echo
    echo
    exit 0
}

[ "$0" = "$BASH_SOURCE" ] && run "$@"
