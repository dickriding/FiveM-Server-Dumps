fx_version 'adamant'
game 'gta5'
files
{
	'gtxd.meta',
	'sp_manifest_1604.ymt'
}
lua54 'yes'
data_file 'GTXD_PARENTING_DATA' 'gtxd.meta'
data_file 'SCENARIO_POINTS_OVERRIDE_FILE' 'sp_manifest_1604.ymt'
this_is_a_map 'yes'

escrow_ignore {
  'sp_manifest.ymt',
  'sp_manifest_1604.ymt',
  'stream/downtown.ymt',
  'stream/downtown_construction_site.ymt',
  'stream/pillbox_hill.ymt',
  'stream/ynd/nodes431.ynd',
  'stream/ynd/nodes463.ynd',
}

escrow_ignore {
  'stream/**/*.ytd',   
  'stream/**/*.ydr',
}
dependency '/assetpacks'