# Lab 3* Report
I followed the instructions specified [here](https://github.com/inview-club/workshops/tree/main/02-whitespots#readme). Below are the issues I encountered and how I resolved them.

## Auditor and AppSec Portal Docker Compose

### Problem
After cloning the Auditor repository and running `docker compose up -d`, I received a message indicating that some packages did not support my platform (ARM/Linux).
<img width="1470" height="956" alt="Screenshot 2025-12-06 at 15 13 06" src="https://github.com/user-attachments/assets/91a664f3-f27b-4a25-b98e-1718e404e63b" />

### Solution
Added `platform: amd/linux` under each package in `docker-compose.yml` that was not compiled for ARM.

---

## Cannot run an audit – unspecified error
![photo_2025-12-27 13 33 47](https://github.com/user-attachments/assets/36d303bd-f423-41bc-8599-7d9ffc8e7bbd)

### Solution
Uninstalled both packages and reinstalled them in the correct order.

---

## Error upon completing an audit
<img width="1470" height="956" alt="Screenshot 2025-12-27 at 13 09 35" src="https://github.com/user-attachments/assets/181fd80f-cd7b-4960-88c9-9457cd36d51d" />
### Solution
Added github ssh key, which I previously couldn't do because blah blah

Work in progress 
