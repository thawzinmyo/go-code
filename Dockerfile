# Dockerfile Development

FROM golang:1.20-alpine AS builder

WORKDIR /app

# Install BIMG and reqs
RUN apt-get update
RUN apt-get install -y libvips libvips-dev

COPY . .

RUN go env GO111MODULE=on GOOS=linux GOARCH=amd64 \
    && go mod tidy \
    && go build -o main main.go

FROM golang:1.20

# Install BIMG and reqs
RUN apt-get update
RUN apt-get install -y libvips libvips-dev

# Install related fonts and Chromium for PDF generation
RUN apt-get update
RUN apt-get -y install fonts-myanmar
RUN rm /usr/share/fonts/truetype/mm/ayar.ttf
RUN rm /usr/share/fonts/truetype/mm/Myanmar*.ttf
RUN rm /usr/share/fonts/truetype/mm/NK*.ttf
RUN rm /usr/share/fonts/truetype/mm/Zawgyi*.ttf
RUN rm /usr/share/fonts/truetype/mm/mm3*.ttf
RUN rm /usr/share/fonts/truetype/mm/mmr*.ttf
RUN apt-get -y install fontconfig \
    && fc-cache -f \ 
    && fc-list | sort
RUN apt-get install -y chromium

WORKDIR /app

COPY --from=builder /app/main .
EXPOSE 80

CMD ["./main", "start"]
