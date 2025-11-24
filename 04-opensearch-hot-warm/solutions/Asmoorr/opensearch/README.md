# How to configure

1. Run docker-compose
2. Run securityadmin.sh when master will have message in log: **[opensearch-master] Not yet initialized (you may need to run securityadmin)**

```bash
docker compose exec opensearch-master bash -c "chmod +x plugins/opensearch-security/tools/securityadmin.sh && bash plugins/opensearch-security/tools/securityadmin.sh -cd config/opensearch-security -icl -nhnv -cacert config/certs/root-ca.pem -cert config/certs/admin.pem -key config/certs/admin.key -h localhost"
```

3. Go to Page opensearch-dashboard (<http://localhost:5601>) and enter with credentials (admin, admin)