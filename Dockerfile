FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY frontend/pubspec.yaml frontend/pubspec.lock* ./
RUN flutter pub get

COPY frontend/ .

ARG API_BASE_URL
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]