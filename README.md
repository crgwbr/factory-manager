The account management team at Maker's Row occasionally enters factory details in an admin page specifically for that reason. In this exercise, you're required to do the following:

## Requirements

### Build it
- Build a web based CRUD app for managing factories - a user should be able to enter factory details and show a list of factories already in the system.
- Details of data for a factory: Name, Email, Address, list of tags
- Host the code on Github
- Have this built in the selected language (we'll pick one for you) in a framework of your choice.

### Deploy it
- Create a Vagrant virtual machine that will host the web application
- Create an Ansible playbook that provisions the Vagrant virtual machine with all the application code and its dependencies
- Application should be accessible through http://localhost:7000/

### Bonus
- Create a stateless REST Api using factory as the resource.
- Plot out the geo locations of the factories in the system and plot them on a US map.

### Be prepared to discuss:
- Learnings along the way
- Challenges

## Developer Notes
- Sinatra (and Ruby in general probably) is odd. I don't like it's approach of implicitly injecting globals. There's too much magic.
    - For example, it's odd to me that I can require a file, but not a single class or function from a file. Basically, namespacing doesn't work like I'd expect.
- I used JWT for authentication in a rather unsafe manor. A couple things I would improve were this a real application:
    - Force SSL everywhere to prevent credential or token eavesdropping.
    - Make JWT tokens one-time use using nonces encoded into the token. After every authenticated API requested, the app would issue the user a new token containing a new nonce. The old nonce would be recorded, thereby invalidating the old token.
    - Include an expiration time in the token so that old tokens are automatically invalidated.
- The API and model code is written pretty simply since it's only a single endpoint. If there were more endpoints, this would need to be abstracted more to keep things DRY.
- Model validation would probably need to be added, but no requirements were given for that, so I didn't build any.
- If the client app were to grow any more complex, I'd use Browserify and Uglify as build tools so that it could be modularized. As it is (single model, handful of views), the single file approach was okay.
- It seems that most of the Ansible roles written around Ruby tasks (like deploying nginx, unicorn, etc) follow the Ruby standard of convention over configuration. Debatable whether thats good or not, but I had to read the code to actually understand what the conventions were. Not a big deal, but documentation of made assumptions would be helpful.
- It's interesting to me how the data mapper library works: it uses mixins rather than inheritance (like say SQLAlchemy, Django ORM, Doctrine). I'm curious what the reasoning was for this and what the consequences are—I'd need to better understand how the Ruby handles objects / classes/ modules to really grok it. Potentially it's an alternative due to lack of support for multiple inheritance.
- I quite like Vagrant and Ansible. I've had some, but limited, exposure to each before. They made VM spin up, networking, and provisioning a breeze.
