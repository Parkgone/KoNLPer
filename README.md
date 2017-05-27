KoNLPer
================

KoNLPer는 [reticulate](https://rstudio.github.io/reticulate/)와 [Flask](flask-docs-kr.readthedocs.io)를 이용해서 \[KoNLP\]의 함수를 POST 요청으로 결과를 받을 수 있도록 구성된 API 서버입니다.
docker image는 [mrchypark/konlper](https://hub.docker.com/r/mrchypark/konlper/)로 바로 사용 가능합니다.

    docker run -p 80:5000 mrchypark/konlper

`ENV`로 사전의 범위를 설정할 수 있습니다. S는 세종사전, N은 NIA사전, W는 우리샘사전입니다. `ENV=S`인 경우 세종사전 추가, `ENV=N`인 경우 NIA사전 추가입니다. `ENV=SNW`는 전체 사전 추가입니다. -(로 만들고 있는 중입니다.)

현재 테스트 서버가 운영중이며 [google app engine](https://appengine.google.com/)에 올리고 [duckdns.org](https://www.duckdns.org/)로 주소를 확보했습니다.
