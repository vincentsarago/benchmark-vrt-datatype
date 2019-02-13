"""cli"""

import click

import rasterio
from rasterio.rio import options
from rasterio.vrt import WarpedVRT
from rio_tiler import utils
import mercantile


@click.command()
@options.file_in_arg
def main(input):
    """Read tile."""
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


if __name__ == '__main__':
    main()
