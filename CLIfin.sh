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
	echo "exit: makes ur computer take over the world for you"
	echo "setup: helps you set up the program"
fi

if [ "$command" = "exit" ]; then
	break
fi 
if [ "$command" = "list" ]; then 
curl -s \
  -H "Authorization: MediaBrowser Token=$API_KEY" \
  "$URL/Items?Recursive=true&IncludeItemTypes=Movie" \
| jq -r '.Items[] | "\(.Id) \(.Name)"'
fi

if [ "$command" = "setup" ]; then
	echo "please input server URL (http://server:port)"
	read -r URL
	#will make a proper login prompt another time , but this is fine.
	echo "please input your API key,"
	read -r API_KEY
	rm -f ~/.config/CLIfin/url ~/.config/CLIfin/apikey
	echo $URL >> ~/.config/CLIfin/url
	echo $API_KEY >> ~/.config/CLIfin/apikey
	echo "complete"
fi
if [ "$command" = "play" ]; then
	echo "please input the movie ID (long scary string of letters and numbers that you can get from the list command)"
	read -r MOVIE_ID
	mpv --vo=tct $URL/Items/$MOVIE_ID/Download?api_key=$API_KEY
		
fi
done 
