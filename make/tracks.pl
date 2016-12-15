while ($a = <>) {
	if (!($a =~ m/\s*[\#\;]/)) { 	# Ignore comment lines
		# match header
		if ($a =~ m/\s*\d+\s*,\s*\d+\s*,\s*Header\s*,\s*\d+\s*,\s*(\d+)\s*,\s*\d+\s*/) {
			print($1);
		}
	}
}