#배포용 컨테이너에 포함시킬 바이너리를 생성하는 컨테이너
#deploy-builder : 릴리스용 빌드를 생성하는 스테이지
FROM golang:1.18.2-bullseye as deploy-builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -trimpath -ldflags "-w -s" -o app

#-----------------------------------------------

#배포용 컨테이너
#deploy: 빌드한 바이너리를 릴리스하기 위한 컨테이너 생성 스테이지
FROM debian:bullseye-slim as deploy

RUN apt-get update

COPY --from=deploy-builder /app/app .

CMD ["./app"]

#------------------------------------------------

#로컬 개발 환경에서 사용하는 자동 새로고침 환경
#dev: 로컬에서 개발할 때에 사용할 컨테이너 생성 스테이지
FROM golang:1.23.1 as dev
WORKDIR /app
RUN go install github.com/air-verse/air@latest
CMD ["air"]