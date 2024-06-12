# CHAT_SYSTEM @instabug
### How to run the project ?
- Install [`docker, docker-compose`](https://docs.docker.com/compose/install/).
- Open your terminal/cmd.
- Run `docker-compose run web rake db:migrate`
- RUN `docker-compose up --build`

### Solution Overview
#### Design
![Screenshot from 2024-06-12 07-54-51](https://github.com/mazoonit/chat_system/assets/29822073/de24d334-bfb4-4a5f-a5d7-c803e36e6068)
- I'm making use of the presistance option in redis, because I can't rely on db only to decide the count.

#### Application Token Storage Optimization
- I generated a uuid token using `SecureRandom` in rails.
- Then used `mysql-binuuid-rails` Gem to store the uuid token as binary value in mysql.

#### Further Notes on scaling approaches which came to my mind.
##### Database scaling
![image](https://github.com/mazoonit/chat_system/assets/29822073/83e35a47-f6c2-4105-8f04-28fd0f276d29)

#### Endpoints
| Method | URL                                                                              | Body                                                 | Description                                                                                                                                                     |
|--------|----------------------------------------------------------------------------------|------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| GET    | /api/applications?page=1&amp;amp;limit=10                                        | None                                                 | Retreive all applications, page and limit defaults are (1,10).                                                                                                  |
| GET    | /api/applications/:application_token                                             | None                                                 | Get single application by token.                                                                                                                                |
| POST   | /api/applications/:application_token                                             | { "name": xxx }                                      | Create application.                                                                                                                                             |
| PUT    | /api/applications/:application_token                                             | { "token": xxx, "name": xxx }                        | Update application.                                                                                                                                             |
| DELETE | /api/applications/:application_token                                             | { "token": xxx }                                     | Delete application.                                                                                                                                             |
| GET    | /api/applications/:application_token/chats                                       | None                                                 | Get all chats, also you can change page, limit parameters which are defaulted to (1,10) by sending page, limit as URL params..                                  |
| GET    | /api/applications/:application_token/chats/:chat_number                          | None                                                 | Get chat.                                                                                                                                                       |
| POST   | /api/applications/:application_token/chats                                       | None                                                 | Create chat.                                                                                                                                                    |
| DELETE | /api/applications/:application_token/chats/:chat_number                          | None                                                 | Delete chat.                                                                                                                                                    |
| GET    | /api/applications/:application_token/chats/:chat_number/messages?query=xx        | None                                                 | Retrieve all messages or search for specific message If you included query parameter, also you can change page, limit parameters which are defaulted to (1,10). |
| GET    | /api/applications/:application_token/chats/:chat_number/messages/:message_number | None                                                 | Get message.                                                                                                                                                    |
| POST   | /api/applications/:application_token/chats/:chat_number/messages                 | { "body": "message_body" }                           | Create message.                                                                                                                                                 |
| PUT    | /api/applications/:application_token/chats/:chat_number/messages                 | { "body": "message_body", "number": message_number } | Update message.                                                                                                                                                 |
| DELETE | /api/applications/:application_token/chats/:chat_number/messages                 | { "number": message_number  }                        | Delete message.                                                                                                                                                 |
