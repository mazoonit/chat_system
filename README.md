# Chat_System @instabug
### How to run the project ? (Please stick to the commands order.)
- Install [`docker, docker-compose`](https://docs.docker.com/compose/install/).
- Open your terminal/cmd and RUN `docker-compose up --build`
- Open another terminal/cmd tab and Run `docker-compose run web rake db:migrate`
- You can access It from `http://localhost:3000` through `postman`,`insomnia`, `browser`, ... etc (You can find endpoints table [here](#Endpoints))

### Solution Overview
#### Design
![Screenshot from 2024-06-12 07-54-51](https://github.com/mazoonit/chat_system/assets/29822073/de24d334-bfb4-4a5f-a5d7-c803e36e6068)
- Workers do write to `elasticsearch` also, web-apis in some endpoints directly access `mysql` and `elasticsearch`.

#### Handling Concurrency, and redis presistance trade-offs.
![image](https://github.com/mazoonit/chat_system/assets/29822073/a9982a8b-869a-4284-8c0b-9fbd04d1e6ce)
- Since We can't rely on mysql getting the chat's max number If there's no data in redis (Because there might be some newly inserted chats in the queue and not inserted into mysql yet) so, I decided to carefully use redis's presistance feature without decreasing the performance drastically.

#### Application Token Storage Optimization
- I generated a uuid token using `SecureRandom` in rails.
- Then used `mysql-binuuid-rails` Gem to store the uuid token as binary value in mysql.

#### Further Notes on scaling approaches which came to my mind.
##### Database scaling
![image](https://github.com/mazoonit/chat_system/assets/29822073/83e35a47-f6c2-4105-8f04-28fd0f276d29)
##### Redis scaling
- Since redis is single-threaded and we're making use of his atomic nature, We may use sharding also and choose the corresponding redis instance based on the application_id using some hash_function or any other sharding method. This way we can scale horizontally while benefiting from the atomic nature. We may face `hot spots` problem also, but to that later there's solutions to keep the data balanced. 
- Also we may use redlock If needed to force concurrently safe state by locks.

#### Endpoints
| Method | URL                                                                              | Body                                                 | Description                                                                                                                                                     |
|--------|----------------------------------------------------------------------------------|------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| GET    | /api/applications?page=1&limit=10                                        | None                                                 | Retreive all applications, page and limit defaults are (1,10).                                                                                                  |
| GET    | /api/applications/:application_token                                             | None                                                 | Get single application by token.                                                                                                                                |
| POST   | /api/applications/:application_token                                             | { "name": xxx }                                      | Create application.                                                                                                                                             |
| PUT    | /api/applications/:application_token                                             | { "token": xxx, "name": xxx }                        | Update application.                                                                                                                                             |
| DELETE | /api/applications/:application_token                                             | None                                     | Delete application.                                                                                                                                             |
| GET    | /api/applications/:application_token/chats                                       | None                                                 | Get all chats, also you can change page, limit parameters which are defaulted to (1,10) by sending page, limit as URL params..                                  |
| GET    | /api/applications/:application_token/chats/:chat_number                          | None                                                 | Get chat.                                                                                                                                                       |
| POST   | /api/applications/:application_token/chats                                       | None                                                 | Create chat.                                                                                                                                                    |
| DELETE | /api/applications/:application_token/chats/:chat_number                          | None                                                 | Delete chat.                                                                                                                                                    |
| GET    | /api/applications/:application_token/chats/:chat_number/messages?query=xx        | None                                                 | Retrieve all messages or search for specific message If you included query parameter, also you can change page, limit parameters which are defaulted to (1,10). |
| GET    | /api/applications/:application_token/chats/:chat_number/messages/:message_number | None                                                 | Get message.                                                                                                                                                    |
| POST   | /api/applications/:application_token/chats/:chat_number/messages                 | { "body": "message_body" }                           | Create message.                                                                                                                                                 |
| PUT    | /api/applications/:application_token/chats/:chat_number/messages/:message_number                 | { "body": "message_body" } | Update message.                                                                                                                                                 |
| DELETE | /api/applications/:application_token/chats/:chat_number/messages/:message_number                 | None                        | Delete message.                                                                                                                                                 |
