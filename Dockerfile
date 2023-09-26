#TODO: 変更する
# ビルドステージ
FROM golang:1.16 AS build-env

# go.modとgo.sumを先にコピー
COPY go.mod go.sum ./

# 依存関係のダウンロード
RUN go mod download

# ソースのコピー
COPY . .

# ビルド
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# 実行ステージ
FROM gcr.io/distroless/base-debian10

# ポートの公開
EXPOSE 8080

# ユーザーをnonrootに設定
USER nonroot:nonroot

# ビルドしたバイナリのコピーと権限の制限
COPY --from=build-env --chown=nonroot:nonroot /go/app .

# バイナリの実行
ENTRYPOINT ["./app"]