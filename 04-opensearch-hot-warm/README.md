# Case #4 – Hot-Warm Architecture

- [Case #4 – Hot-Warm Architecture](#case-4--hot-warm-architecture)
  - [Goal](#goal)
  - [Stack](#stack)
  - [Checkpoints](#checkpoints)
  - [Result](#result)
  - [Contacts](#contacts)

## Goal

To save space when storing logs, prepare an architecture and set up the index lifecycle for log storage.

## Stack

![Opensearch](https://img.shields.io/badge/opensearch_2.19-005EB8.svg?style=for-the-badge&logo=OpenSearch&logoColor=white)

## Checkpoints

1. Deploy a [cluster](https://docs.opensearch.org/latest/tuning-your-cluster/#advanced-step-7-set-up-a-hot-warm-architecture) of 5 nodes with the following settings:
   - 1 master node
   - 4 data nodes:
     - 2 nodes with the hot attribute
     - 2 nodes with the warm attribute
2. Create an [index template](https://docs.opensearch.org/latest/im-plugin/index-templates/) with the following configurations:
   - Template type: Data streams
     - Time field: timestamp
   - Index pattern: logs
   - 1 shard
   - 1 replica
   - New shards are created on nodes with the hot attribute
   - Index mappings:
     - level: keyword
     - trace_id: keyword
     - service: keyword
     - host: keyword
     - timestamp: date
     - message: text
3. Set up an [index policy](https://docs.opensearch.org/latest/im-plugin/ism/index/) as follows:
   - Initial state: hot.
     - Actions:
       - Rollover:
         - Minimum index age: 1 minute
         - Minimum index size: 100 MB
     - Transition:
       - Target state: warm
       - Trigger: Minimum index age: 1 minute
   - State: warm
     - Actions:
       - Allocation:
         - Node must have warm attribute
     - Transition:
       - Target state: delete
       - Trigger: Minimum index age: 1 minute
   - State: delete
     - Actions:
       - Delete
4. Load data with any tool and observe how shards go through each lifecycle stage. You may use [our tool](https://github.com/inview-club/synthetica).
5. (Optional) Repeat the index template and policy setup using **Dev Tools**.

## Result

1. Using the **GET _cat/nodeattrs** query, retrieve the temperature attribute of the nodes.
2. On the **Policy managed indexes** tab, data streams attached to the created policy are displayed, along with their current state and ongoing actions[web:1].
3. Using the **GET _cat/shards?v** query, all index shards should have a **STARTED** status and be located initially on hot nodes, then on warm nodes, and finally be deleted.

## Contacts

Need help? Write in [our Telegram chat](https://t.me/+nSELCyIX8ltlNjU6)
