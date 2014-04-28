##Deal.iz.io - Version 1

Deal.iz.io was my first steps in iOS development. It combined an iOS client and backend API that aggregated deals for users to thumb through. Our server would continuously update it's backend to provide a one-stop shop for updating deals on the client.

Features include:
- Simplistic API
- Auto updating, crawling of deal sites
- Basic metrics - we were always collecting information and could provide useful insights on-demand. We did not have a crafty admin backend for it, though.

###Highly bandwidth intensive
The idea behind the server backend made sense during spec stages, but we ended up with insanely high bandwidth charges. Polling was too frequent, but less frequent polling could have resulted in missed deals. We were investigating PubSubHubbub before the rewrite was to take place.

###License
Although the source is currently open, it is not currently licensed for use. For more information, please contact me.