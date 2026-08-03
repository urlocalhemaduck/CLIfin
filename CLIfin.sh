#!/bin/bash
#makes and points variables to the correct folder
mkdir -p ~/.config/CLIfin
touch ~/.config/CLIfin/apikey
touch ~/.config/CLIfin/url
API_KEY=$(<~/.config/CLIfin/apikey)
URL=$(<~/.config/CLIfin/url)
echo "welcome to CLIfin, first time? run the setup command"
#for now i will just make a simple interface where you just enter commands
while true; do
read -r command

if [ "$command" = "help" ]; then
	echo "list: lists movies"
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
if [ "$command" = "list" ]; then 
	curl -s \
 	 -H "Authorization: MediaBrowser Token=$API_KEY" \
  	"$URL/Items?Recursive=true&IncludeItemTypes=Movie" \
	| jq -r '.Items[] | "\(.Id) \(.Name)"'
fi
if [ "$command" = "music" ]; then 
curl -s \
  -H "Authorization: MediaBrowser Token=$API_KEY" \
  "$URL/Items?Recursive=true&IncludeItemTypes=MusicAlbum" \
| jq -r '.Items[] | "\(.Id) \(.Name)"'
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
curl -s \
  -H "Authorization: MediaBrowser Token=$API_KEY" \
  "$URL/Items?Recursive=true&IncludeItemTypes=Series" \
| jq -r '.Items[] | "\(.Id) \(.Name)"'
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
if [ "$command" = "setup" ]; then
	reset 
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
fi
if [ "$command" = "play" ]; then
	echo "please input the movie ID (long scary string of letters and numbers that you can get from the listing commands)"
	read -r MOVIE_ID
	mpv --vo=tct $URL/Items/$MOVIE_ID/Download?api_key=$API_KEY
	reset
		
fi
done 
