#!/bin/bash
#makes and points variables to the correct folder
mkdir -p ~/.config/CLIfin
touch ~/.config/CLIfin/apikey
touch ~/.config/CLIfin/url
API_KEY=$(<~/.config/CLIfin/apikey)
URL=$(<~/.config/CLIfin/url)
media_browser () {
  local include_type="${1:-Movie MusicAlbum Series}"
  curl -s \
 	 -H "Authorization: MediaBrowser Token=$API_KEY" \
  	"$URL/Items?Recursive=true&IncludeItemTypes=$include_type" \
	| jq -r '.Items[] | "\(.Id) \(.Name)"'
}
#i defined the setup here, because it is used twice, and copy and pasting it would be a waste of space, and would be harder to maintain.
run_setup ()
{	reset 
	echo "please input server URL (http://server:port)"
	read -r URL
	#will make a proper login prompt another time , but this is fine.
	echo "please input your API key,"
	read -r API_KEY
	rm -f ~/.config/CLIfin/url ~/.config/CLIfin/apikey
	echo $URL >> ~/.config/CLIfin/url
	echo $API_KEY >> ~/.config/CLIfin/apikey
	#this stores the url and api key in normal unencrypted text, which is a minor security risk, and needs to be fixed before or at the same time as converting username and password into an API key.
	echo "complete"
	reset
}

if [ -z "$API_KEY" ] || [ -z "$URL" ]; then
	run_setup
fi
echo "welcome to CLIfin!"
#for now i will just make a simple interface where you just enter commands
while true; do
read -r command

if [ "$command" = "help" ]; then
	echo "movies: lists movies"
	echo "music: lists music albums"
	echo "exit: makes ur computer take over the world for you"
	echo "setup: helps you set up the program"
	echo "play: plays a movie, show, or song"
	echo "series: lists TV series"

fi

if [ "$command" = "exit" ]; then
	reset
	break
fi 
if [ "$command" = "movies" ]; then 
	media_browser "Movie"
fi
if [ "$command" = "music" ]; then 
	media_browser "MusicAlbum"
	echo "pick an album (enter ID) to list songs (0 to go back)"
	read -r ALBUM_ID
	if [ "$ALBUM_ID" != "0" ]; then
curl -s \
	  -H "Authorization: MediaBrowser Token=$API_KEY" \
	  "$URL/Items?ParentId=$ALBUM_ID&Recursive=true&IncludeItemTypes=Audio" \
	| jq -r '.Items[] | "\(.Id) \(.Name)"'
	
fi 
fi
if [ "$command" = "series" ]; then
	media_browser "Series"
	echo "pick a series (enter ID) to list seasons (0 to go back)"
	read -r SERIES_ID
	if [ "$SERIES_ID" != "0" ]; then
curl -s \
	  -H "Authorization: MediaBrowser Token=$API_KEY" \
	  "$URL/Items?ParentId=$SERIES_ID&Recursive=true&IncludeItemTypes=Season" \
	| jq -r '.Items[] | "\(.Id) \(.Name)"'
	echo "pick a season (enter ID) to list episodes (0 to go back)"
	read -r SEASON_ID
	if [ "$SEASON_ID" != "0" ]; then
curl -s \
	  -H "Authorization: MediaBrowser Token=$API_KEY" \
	  "$URL/Items?ParentId=$SEASON_ID&Recursive=true&IncludeItemTypes=Episode" \
	| jq -r '.Items[] | "\(.Id) \(.Name)"'
fi
fi
fi
#the code for the series and music commands are identical besides variables, so any code changes in one should be carried over to the other too. 
#it should just be a thing() thing, would be easier to maintain, and more efficient, but i couldnt get it working in a clean way, so thats for another time.
if [ "$command" = "setup" ]; then
	run_setup
fi
if [ "$command" = "play" ]; then
	echo "please input the movie ID (long scary string of letters and numbers that you can get from the listing commands)"
	read -r MOVIE_ID
	mpv --vo=tct $URL/Items/$MOVIE_ID/Download?api_key=$API_KEY
	reset
		
fi
done