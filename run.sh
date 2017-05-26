docker kill kr
docker rm kr
docker build -t mrchypark/konlper .
docker run -p 5000:5000 --name kr mrchypark/konlper