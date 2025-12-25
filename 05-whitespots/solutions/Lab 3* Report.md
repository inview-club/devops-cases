I followed the instructions smoothly but once I got to Auditor configuration, I realized I didn't know where I could get an auth_token generated during the installation process.
Passage 1. of the instruction points out that it can be found in auditor/.env, where I had put it previously. I ran auditor rm -rf instead, in hopes of generating a new key. 
The previous one was still stored inside an auditor container, so i had to rebuild it, which didn't help the situation because by the time I was done, my Whitespots license had expired. 

