FROM ballerina/ballerina:latest

WORKDIR /app

COPY . .

RUN bal build

EXPOSE 9001

CMD ["bal", "run"]
