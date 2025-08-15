# Case №3 - Migration

<div align="center">

  ![Result diagram dark](img/03-opensearch-migration-dark.png#gh-dark-mode-only)

</div>

<div align="center">

  ![Result diagram light](img/03-opensearch-migration-light.png#gh-light-mode-only)

</div>

- [Case №3 - Migration](#case-3---migration)
  - [Goal](#goal)
  - [Stack](#stack)
  - [Adding New Nodes](#adding-new-nodes)
    - [Checkpoints](#checkpoints)
    - [Result](#result)
  - [Reindexing to a Remote Cluster](#reindexing-to-a-remote-cluster)
    - [Checkpoints](#checkpoints-1)
    - [Result](#result-1)
  - [Contacts](#contacts)

## Goal

Organize data transfer in OpenSearch for the following scenarios:

- Adding new nodes to production and decommissioning old ones;
- Reindexing to a remote cluster.

## Stack

![Opensearch](https://img.shields.io/badge/opensearch-005EB8.svg?style=for-the-badge&logo=OpenSearch&logoColor=white)

## Adding New Nodes

### Checkpoints

1. Deploy 2+ OpenSearch nodes and connect them into a single [cluster](https://docs.opensearch.org/docs/latest/install-and-configure/configuring-opensearch/cluster-settings#cluster-level-routing-and-allocation-settings);
2. Create an index to be transferred and populate it with data;
3. Disable automatic index rebalancing in the cluster;
4. Add new nodes to the cluster;
5. Add old nodes to the rebalance exclusion list;
6. Enable automatic rebalancing;
7. Wait for the index transfer process to complete;
8. Disconnect the old nodes;

### Result

When running the GET _cat/shards?v query, all shards of the index must have the status *STARTED* and reside on the new nodes. After disconnecting the old nodes, the index status must be *Green*.

## Reindexing to a Remote Cluster

### Checkpoints

1. Deploy 2 clusters, each having 2+ OpenSearch nodes;
2. Add permission in the `opensearch.yml` file to allow the use of a remote cluster for reindexing;
3. Create an index in the target cluster with the same settings and mappings as the source cluster;
4. Execute a [reindexing request](https://docs.opensearch.org/docs/latest/im-plugin/reindex-data/), specifying the source index on the remote cluster;
5. Wait for the data transfer to complete.

### Result

Both clusters must have indexes with the same number of documents.

## Contacts

Feel free to ask questions in [our Telegram chat](https://t.me/+nSELCyIX8ltlNjU6)!
