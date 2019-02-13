# benchmark-vrt

```
$ git clone http://github.com/vincentsarago/benchmark-vrt
$ cd benchmark-vrt

$ docker login

$ make build

$ make test
```

## Benchmark
Checking if mask data is fetched for different GDAL datatype and 1 or 3 bands dataset.

### Test

```python
tile = "9-150-183"

tile_z, tile_x, tile_y = list(map(int, tile.split('-')))
mercator_tile = mercantile.Tile(x=tile_x, y=tile_y, z=tile_z)
tile_bounds = mercantile.xy_bounds(mercator_tile)

with rasterio.open(input) as src:
    mask = src.dataset_mask()
    rRead = "OK" if mask[0][0] == 0 else "NOK"

    _, mask = utils.tile_read(src, tile_bounds, 512, indexes=src.indexes)
    rTiler = "OK" if mask[0][0] == 0 else "NOK"

    with WarpedVRT(src, add_alpha=True) as vrt:
        mask = vrt.dataset_mask()
    rVrt = "OK" if mask[0][0] == 0 else "NOK"

    click.echo(f"Read: {rRead} Tiler: {rTiler} VRT: {rVrt}")
```

#### 1. Read mask
#### 2. Read tile using rio-tiler
![tile](https://user-images.githubusercontent.com/10407788/52730039-76ff2080-2f88-11e9-9aad-40e47b7505f1.png)

#### 3. Read mask from simple VRT



### Results

**Rasterio: 1.0.18** and **GDAL: 2.4.0**

```
1 band dataset

Byte
Read: OK Tiler: OK VRT: OK

real	0m1.401s
user	0m0.970s
sys	0m0.170s

Int16
Read: OK Tiler: NOK VRT: NOK

real	0m0.483s
user	0m0.310s
sys	0m0.080s

Int32
Read: OK Tiler: NOK VRT: NOK

real	0m0.463s
user	0m0.300s
sys	0m0.100s

Uint16
Read: OK Tiler: OK VRT: OK

real	0m1.850s
user	0m1.580s
sys	0m0.120s

Uint32
Read: OK Tiler: NOK VRT: NOK

real	0m0.445s
user	0m0.310s
sys	0m0.080s

Float32
Read: OK Tiler: NOK VRT: NOK

real	0m0.497s
user	0m0.340s
sys	0m0.070s

Float64
Read: OK Tiler: NOK VRT: NOK

real	0m0.463s
user	0m0.300s
sys	0m0.080s
------
3 bands dataset

Byte
Read: OK Tiler: OK VRT: OK

real	0m1.518s
user	0m1.300s
sys	0m0.130s

Int16
Read: OK Tiler: NOK VRT: NOK

real	0m0.640s
user	0m0.400s
sys	0m0.130s

Int32
Read: OK Tiler: NOK VRT: NOK

real	0m0.622s
user	0m0.440s
sys	0m0.090s

Uint16
Read: OK Tiler: OK VRT: OK

real	0m3.801s
user	0m3.360s
sys	0m0.170s

Uint32
Read: OK Tiler: NOK VRT: NOK

real	0m0.605s
user	0m0.420s
sys	0m0.100s

Float32
Read: OK Tiler: NOK VRT: NOK

real	0m0.609s
user	0m0.430s
sys	0m0.090s

Float64
Read: OK Tiler: NOK VRT: NOK

real	0m0.636s
user	0m0.420s
sys	0m0.120s
```

:point_up: this confirm my though expressed in https://github.com/OSGeo/gdal/pull/742#issuecomment-462818883


#### The Fix

Using https://github.com/vincentsarago/gdal/commit/496f78e47e57a171073cd9f11f991449df49cc84seems to fix the problem. Basically the fix is to allow alpha band for all datatype.

**Rasterio: 1.0.18** and **GDAL: 2.4.0**

```
1 band dataset

Byte
Read: OK Tiler: OK VRT: OK

real	0m1.178s
user	0m0.920s
sys	0m0.150s

Int16
Read: OK Tiler: OK VRT: OK

real	0m1.704s
user	0m1.480s
sys	0m0.130s

Int32
Read: OK Tiler: OK VRT: OK

real	0m1.928s
user	0m1.640s
sys	0m0.210s

Uint16
Read: OK Tiler: OK VRT: OK

real	0m1.673s
user	0m1.460s
sys	0m0.140s

Uint32
Read: OK Tiler: OK VRT: OK

real	0m1.941s
user	0m1.680s
sys	0m0.170s

Float32
Read: OK Tiler: OK VRT: OK

real	0m1.819s
user	0m1.560s
sys	0m0.180s

Float64
Read: OK Tiler: OK VRT: OK

real	0m2.254s
user	0m1.920s
sys	0m0.130s
------
3 bands dataset

Byte
Read: OK Tiler: OK VRT: OK

real	0m1.465s
user	0m1.270s
sys	0m0.090s

Int16
Read: OK Tiler: OK VRT: OK

real	0m3.427s
user	0m3.170s
sys	0m0.180s

Int32
Read: OK Tiler: OK VRT: OK

real	0m4.095s
user	0m3.800s
sys	0m0.220s

Uint16
Read: OK Tiler: OK VRT: OK

real	0m3.410s
user	0m3.240s
sys	0m0.090s

Uint32
Read: OK Tiler: OK VRT: OK

real	0m4.203s
user	0m4.030s
sys	0m0.110s

Float32
Read: OK Tiler: OK VRT: OK

real	0m3.858s
user	0m3.670s
sys	0m0.100s

Float64
Read: OK Tiler: OK VRT: OK

real	0m4.646s
user	0m4.250s
sys	0m0.180s
```

## Performance

as noted in https://github.com/cogeotiff/rio-tiler/issues/78 there are some perforance issues, which seems to come from the VRT + Alpha (`add_alpha=True`) implementation.

GDAL 2.4.0

Type | Byte | Int16 | Int32 | UInt16 | UInt32 | Float32 | Float64
---  | ---  | ---   | ---   | ---    | ---    | ---     | ---
time (s) | 0.437 | 0.375 | 0.371 | 1.054 | 0.420 | 0.381 | 0.399
Status | OK  | NOK   | NOK   | OK    | NOK   | NOK   | NOK

GDAL 2.4.0 + FIX

Type | Byte | Int16 | Int32 | UInt16 | UInt32 | Float32 | Float64
---  | ---  | ---   | ---   | ---    | ---    | ---     | ---
time (s) | 0.402 | 1.057 | 1.103 | 1.053 | 1.113 | 1.098 | 1.108
Status | OK  | OK    | OK    | OK    | OK    | OK    | OK

:point_up: numbers for mask tile reading using rio-tiler (VRT)
