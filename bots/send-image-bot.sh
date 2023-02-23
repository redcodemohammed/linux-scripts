CHANNEL_ID="-1001696669044"
BOT_TOKEN="851004617:AAHtASvhU_G_tOr_BJNmwsuHxnFD_4A5V04"
IMAGES_FOLDER="pictures"
PHOTO_URL="$IMAGES_FOLDER/1.png"

curl -F "chat_id=$CHANNEL_ID" -F "photo=@$PHOTO_URL" \
https://api.telegram.org/bot$BOT_TOKEN/sendphoto

rm $PHOTO_URL
