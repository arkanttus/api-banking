# API Banking Stone

> This project is the final challenge in Programa de Formação em Elixir - Stone

To run this project you need up the database in a docker container in port 5433. To make this you must run the bellow command:

```sh
docker-compose up -d
```
# Database and Migrations

Run the bellow command in root folder to create database and migrations:
```sh
mix setup
```

# Tests

To run tests, in root folder execute:
```sh
mix test
```

# API Endpoints

## - Create User and Account

Create an User and a Account

`POST  /api/users`

Body Params:
```
name*: string
email*: string
email_confirmation*: string
password*: string

* Required fields
```
Example:
```json
{
	"name": "yasuo",
	"email": "yasuo@mail.com",
	"email_confirmation": "yasuo@mail.com",
	"password": "OpaiTaON"
}
```

## - Withdraw

Withdraws to an existing account.

`POST  /api/withdraw`

Body Params:
```
account_code*: UUID
amount*: integer (Value in Real cents. Ex: R$1 is 100 cents)
description: string

* Required fields
```
Example:
```json
{
	"account_code": "123456",
	"amount": 5000,
	"description": "test"
}
```

## - Transfer between accounts

Transfer between existing accounts.

`POST  /api/transfer`

Body Params:
```
account_origin_code*: UUID
account_target_code*: UUID
amount*: integer (Value in Real cents. Ex: R$1 is 100 cents)
description: string

* Required fields
```
Example:
```json
{
	"account_origin_code": "123456",
	"account_target_code": "424242",
	"amount": 25000,
	"description": "Test"
}
```
