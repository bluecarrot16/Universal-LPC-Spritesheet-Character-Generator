out_dir="../../spritesheets/hair"


# most hairstyles are drawn as 8 individual images ({n, e, s, w, s-hurt{2,3,4}}.png). For these,
# first assemble a complete spritesheet, then make a set of reclors. 
echo "STYLES"
for hair in $(find . -maxdepth 1 -mindepth 1 -type d); do
	echo $hair

	for sex in 'male' 'female'; do
		lpctools arrange distribute \
			--input $hair/*.png --output $out_dir/$hair/$sex.png \
			--layout universal --offset reference_points_$sex.png --mask masks_$sex.png
		lpctools colors recolor --input $out_dir/$hair/$sex.png --mapping ./palettes.json
	done
done


# for a few hairstyles, I just had the full spritesheet already and didn't bother to split
# into individual images. If you wanted to do that, you could use `distribute_repack`
echo "FULL SHEET STYLES"
hair_full_sheet=../hair_full_sheet

for hair in $(find $hair_full_sheet -maxdepth 1 -mindepth 1 -type d -exec basename {} \;); do
	echo $hair

	for sex in 'male' 'female'; do
		if [ -f "$hair_full_sheet/$hair/$sex/bg.png" ]; then
			lpctools arrange distribute-repack \
				--input bg=$hair_full_sheet/$hair/$sex/bg.png main=$hair_full_sheet/$hair/$sex/main.png \
				--output $out_dir/$hair/$sex.png \
				--from universal --to universal --mask masks_$sex.png
		else
			lpctools arrange distribute-repack \
				--input $hair_full_sheet/$hair/$sex/main.png \
				--output $out_dir/$hair/$sex.png \
				--from universal --to universal --mask masks_$sex.png
		fi

		lpctools colors recolor --input $out_dir/$hair/$sex.png --mapping ./palettes.json
	done
done


# all that follows is just for making the big grid preview image with all styles x all colors
preview_dir="../_preview/_hair"

mkdir -p "$preview_dir/body"
mkdir -p "$preview_dir/tiles"


echo "BUILDING PREVIEW"
for hair in $(find "$out_dir" -maxdepth 1 -mindepth 1 -type d | sort); do
	echo $(basename $hair)
	for color in $(find "$hair/male" -maxdepth 1 -mindepth 1 | sort); do
		tilefile=$preview_dir/tiles/$(basename $hair)-$(basename $color)
		echo "$color > $tilefile"
		magick -extract 64x64+64+64 $color $tilefile
		outfile=$preview_dir/body/$(basename $hair)-$(basename $color)
		magick composite -gravity center "$tilefile" "$preview_dir/body.png"    "$outfile"
	done
	n_colors=$(ls "$hair/male" | wc -l)
done

montage -border 0 -geometry 64x64 -tile "$n_colors"x $preview_dir/body/*.png $preview_dir/preview.png
