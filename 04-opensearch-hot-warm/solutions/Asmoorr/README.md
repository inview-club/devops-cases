# Case #4 – Opensearch Hot-Warm Architecture

<div align="center">

![Result diagram dark](../../img/04-opensearch-hot-warm-dark.png#gh-dark-mode-only)

</div>

<div align="center">

![Result diagram light](../../img/04-opensearch-hot-warm-light.png#gh-light-mode-only)

</div>

## Acknowledgments

First of all, thank you for your workshop. It was really interesting and I look forward to visit the next one. So, here
is my sollution of this case. Now, let's get started:

## Preparing

After forking and clonning the repository we need to run Docker containers and set up basic stuff in OpenSearch

According to the instruction run all the services from Dockercompose file and run securityadmin:

> [!tip]
> 1. Run docker-compose
> 2. Run securityadmin.sh when master will have message in log: **[opensearch-master] Not yet initialized (you may need
     to run securityadmin)**
>
> ```bash
> docker compose exec opensearch-master bash -c "chmod +x plugins/opensearch-security/tools/securityadmin.sh && bash plugins/opensearch-security/tools/securityadmin.sh > -cd config/opensearch-security -icl -nhnv -cacert config/certs/root-ca.pem -cert config/certs/admin.pem -key config/certs/admin.key -h localhost"
> ```
>
> 3. Go to Page opensearch-dashboard (<http://localhost:5601>) and enter with credentials (admin, admin)
> ```

securityadmin initializes the OpenSearch Security plugin for the cluster. Without this step the master node keeps
printing `Not yet initialized (you may need to run securityadmin)` and the cluster runs with a temporary default
security configuration

![run dockercompose](imgs/image.png)
![run securityadmin 1](imgs/image-1.png)
![run securityadmin 2](imgs/image-2.png)

Now we can go to web interface and start working with OpenSearch UI

After logging with standard `admin` `admin` credentials

![logging](imgs/image-3.png)

Go to `Management` -> `Index Management` and here we can see our State management policies, in our case:) this is
`hot_warm ` one

![index management](imgs/image-4.png)

Clicking on it, we can manage whole workflow. There are 3 sections:

1. First
   ![first](imgs/image-8.png)
   In the first section we see the **Policy settings** for the `hot_warm` policy. This page shows the policy identifier,
   description, default state (`hot`), current schema or sequence numbers, last updated time and optional error
   notification settings


2. Second
   ![second](imgs/image-9.png)
   The second section is **ISM templates**. Here we define which indexes or data streams will automatically use this
   policy. In my case the template contains an index pattern that matches `logs` indexes and a priority value, so every
   new backing index created for the `logs` data stream automatically gets the `hot_warm` policy attached


3. Third, main
   ![third 1](imgs/image-10.png)
   ![third 2](imgs/image-11.png)
   The third, main section shows the **States** of the policy. It visualises the lifecycle of an index: it starts in the
   `hot` state, where a rollover action is triggered after the index reaches the configured age and size, then
   transitions to the `warm` state, and finally goes to the `delete` state, where the index is removed

Also, we can check out created Data stream `logs`
![datasteram](imgs/image-12.png)

This is created template `logs`

![template](imgs/image-14.png)

To be completely agreed with the given task in workshop, I created two extra containers with warm & hot nodes, so now we
have 5 of them:
![alt text](imgs/image-13.png)

And finally we can see green indexes in `Indexes` page:

![alt text](imgs/image-15.png)