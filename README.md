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
account_code*: string
amount*: integer (Value in Real cents. Ex: R$1 is 100 cents)
description: string

* Required fields
```
Example:
```json
{
	"account_code": "123456",
	"amount": 5000
}
```

## - Transfer between accounts

Transfer between existing accounts.

`POST  /api/transfer`

Body Params:
```
account_origin_code*: string
account_target_code*: string
amount*: integer (Value in Real cents. Ex: R$1 is 100 cents)
description: string

* Required fields
```
Example:
```json
{
	"account_origin_code": "123456",
	"account_target_code": "424242",
	"amount": 25000
}
```

## - Get Account's Bank Statement

Get a bank statement with details of all account's transfers

`GET /api/accounts/<account_id>/statement`

Path Params:
```
account_id: UUID 
```

Example Request:
`GET /api/accounts/47649d77-091c-4392-8826-2ccc161490d2/statement`

Example Response:
```json
[
  {
    "amount": 200,
    "date": "2021-04-20T16:32:07",
    "operation": "transfer",
    "title": "Transferência Enviada",
    "transfer_to": "dc719739-9937-47eb-a02f-e218749e1a79"
  },
  {
    "amount": 200,
    "date": "2021-04-20T16:31:41",
    "operation": "transfer",
    "title": "Transferência Recebida",
    "transfer_from": "dc719739-9937-47eb-a02f-e218749e1a79"
  },
  {
    "amount": 10,
    "date": "2021-04-20T16:30:15",
    "operation": "withdraw",
    "title": "Saque"
  }
]
```
