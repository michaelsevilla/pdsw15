We thank the reviewers for their time and thoughtful suggestions.

# General questions
###1. Why is there a limited number of workloads? Are they representative of HPC? Are the results specific to CephFS?
(reviewer 1, 2, 4)

We take a comprehensive look at 3 balancers for a smaller number of workloads to show how load is split across MDSs. Since our contribution is a general API/framework for specifying different balancers, we emphasize Mantle's ability to explore different strategies on the same storage system, instead of drawing conclusions about which balancers are best for a given workload (this is future work).

Checkpoint/restart (e.g., concurrent creates) is a common HPC paradigm that is terrible for metadata services (as reviewer 4 notes). We use it because it (1) stresses the system, (2) is the focus of other state-of-the-art metadata systems (e.g., GIGA+), and (3) is a real problem (see related work). Compiling the Linux kernel is not as common, but we choose it because it has different metadata request types/frequencies and because users plan to use CephFS as a backup repository, shared file system, file server, or compute backend.

###2. How does Mantle scale? Are the performance numbers specific to CephFS?
(reviewer 3, 4, 5)

We agree that scalability is important. But please keep in mind that many parallel file systems deployed in today's production environments use a metadata service that is still limited to a very small number of nodes (less than 10, often less than 5). We found that our balancer in its current state is robust until about 20 nodes, at which point there is increased variability in the client's performance (as reviewer 3 notes) for reasons that we are still investigating. A deeper scalability analysis is future work. We suspect many interesting problems with the current architure (e.g., the memory pressure with many cold files and the n-way communication model for the MDSs, as noted by reviewer 4) and we are working with the Ceph team on some of these early issues. 

The raw performance numbers in the paper are specific to CephFS, but we emphasize that Mantle is a tool for exploring load balancing in distributed file systems. In this paper, we explore infrastructures for better understanding of how to balance diverse distributed metadata workloads as they might occur in real production environments (not just file create workloads), and ask the question "for a given workload, is it better (1) to immediately spread load aggressively or (2) to first understand the capacity of MDS nodes before splitting load at the right time under the right conditions?" We show how the second option can lead to better performance but at the cost of increased complexity. While we do not come up with a solution that is better than state-of-the-art systems optimized for file creates (e.g., GIGA+), we do present a framework that allows users to study the emergent behavior of different strategies, both in research and in the classroom.

Mantle is not a competitor to GIGA+; we just use the GIGA+ strategy to better understand the different techniques of spreading load. We are not arguing that Mantle is more scalable or better performing than GIGA+, so future revisions will do a better job of placing Mantle in the correct context, in relation to related work.

### 4. Can this technique be more sophisticated?
(reviewer 1, 4, 5)

For future work, we will layer sophisticated balancers, with different metrics, statistical modeling, control feedback loops, and machine learning techniques, on top of Mantle. Mantle's ability to save state is a feature aimed at supporting such layers. One issue, as noted by reviewer 5, is that the current prototype doesn't stop the administrator from doing stupid things, like spawning threads, using all the memory to write state, or injecting a "while 1". 

# Detailed Feedback
## Reviewer 2: 
### 1. What are the contributions? If the contribution is the effect that policies have on behavior, there needs to be a more comprehensive set of workloads.

Although we strive to quantify the effect that policies have on performance, in this paper we only show how certain policies can improve or degrade performance. We stay away from finding the best balancers for many different workloads and instead focus on how the API is flexible to enough to express many strategies. Of course, running a suite of workloads over Mantle is future work. We agree that separating policy from mechanism is not a novel contribution, so in future revisions, we will focus our contributions on the balancing API and the framework for testing different strategies.

## Reviewer 3:
### 1. Can I trust the metrics that Mantle uses, especially, since their effects on the system as a whole has such variability?

Finding the metrics that reflect the systems state is one of the main use cases for Mantle! Mantle pulls out ALL the metrics that could be important (i.e. ones that we think, based on empirical evidence, are important) so that the adminsistrator can freely explore them. Unfortunately, if we need a metric that Mantle doesn't expose, we need to open up CephFS and add it - but this overhead isn't any worse than what we'd have to do with plain old CephFS. For example, one of the metrics that we started with was a running average of the CPU utilization, but we deteremined that this is insufficient for flash crowds, so we had to modify Mantle to expose the instantaneous CPU utilization. 

### 2. What empirical observations/tests helped us arrive at the heuristics in the paper?

The heuristics we explore are from related work. Spill evenly is from GIGA+, fill and spill is a variation of LARD (we actually didn't see this paper until recently, but it will cited in the final version), and the adaptable balancer is the original CephFS policy. We find thresholds for the spill and fill technique using the latency vs. throughput graph in Fig. 5, but for the most part, these heuristics are just starting points for showing the power of Mantle and we are not ready to make grandiose statements about which is best... yet. The revised version of the paper will condense the background sections (2 and 3) to make room for this explanation.

## Reviewer 4:
### 1. Is the complexity and poor behavior arguments AGAINST the use of dynamic subtree partitioning? 

Yes, the paper spends too much time framing the complexity of dynamic subtree partitioning, but the takeaway should have been that  Mantle's flexibility is appealing and warrants exploration. In future versions of the paper, we will compress Section 3 and rename it "Dynamic Subtree Paritioning Challenges". 

### 2 What is the basic client-server metadata protocols? Is there a cost model? How does the MDS forward work? Why is there so much overhead?

The last two bullets in Section 2.2 allude to the protocols but do a poor job of explaining them. Future versions will have a whole section devoted to it. As the reviewer notes, the papers are old and do not explain the protocols either, so for more information, see Sage's thesis and the code, which is open source. To answer your questions: 

MDS/Client interaction: MDS nodes and clients cache a configurable number of inodes. For creates, the client will issue a getattr, lookup, and create. Before reaching out to the MDS, the client will try to resolve the getattr and lookup locally (not the create itself like proposed in batchFS). 

Forwards: MDS nodes maintain the subtree boundaries and redirect requests to the "authority" MDS if a client's request falls outside of its jurisdiction. As the client receives responses, it builds up its own mapping of the namespace subtrees to MDS nodes. If the subtrees are partitioned poorly across the MDS nodes (e.g., the root inode is on MDS1 and the rest are on MDS2), then path traversals incurr many forwards. 

Permissions: the MDS alters flags (saved in the directory as a state machine) to control writes and reads permissions. For coherency, MDSs will do a scatter-gather process, which has each MDS halt updates on a directory, send stats around the cluster, and then wait for the authoritative MDS to send back new data. These are done inside sessions (discussed in Section 5.1.1), which drag down our performance and leads to the less than desirable 18% slowdown from 1 MDS to 2 MDSs. 

Future revisions of the paper will expand on Section 2.4 and Fig. 3, as the success of dynamic subtree partitioning is contingent on whether these factors are true. We will also expand on GIGA+ in the related work, because it was never our intention to "dismiss" GIGA+, rather, we want to highlight its strategy in comparison to other strategies using Mantle. While it is natural to compare raw performance numbers in an apples-to-apples way, we feel (and not just because GIGA+ outperforms Mantle) that we are attacking an orthogonal issue by providing a system for which we can test the strategies of the systems, rather than the systems themselves.
### 3. What are the advantages of Mantle over a sharded key value store? If the answer is locality, I don't buy it.

Mantle explores the benefits of locality and hashing. The advantages of locality are:
- reducing requests: refers to "forwarded requests" between MDS nodes (see question 2). Figure 3 alters the degree of locality by changing how metadata is distributed; with less locality, the performance gets worse and the number of requests increases. As you noted, client caching can reduce the requests between clients and MDS nodes, but CephFS (as well as many other file systems) do not have that design, for a variety of reasons.
- lowering communication: refers to the coherency protocols for maintaing permissions (see question 2).
- memory pressure: refers to the memory needed to cache path prefixes for improving path traversals. If metadata is spread, the MDS cluster replicates parent inode metadata so that path traversals can be resolved locally.

Most of these arguments are made in SC'06 paper, but we agree they are extremeley relevant, so in future revisions, we will devote a whole section it.

### 4. Why do we compare against running a single client running a single make?

We agree that 1 client compiling with 1 MDS isn't interesting, but the point of Figure 9 is that Mantle can spread metadata across the MDSs in different ways. The interesting result is 3 clients don't saturate the system enough to make distribution worthwhile and that 5 clients with 3 MDSs is just as efficient as 4 or 5 clients.

### 5. Why does reproducibility prevent us from using error bars?

You are correct, this will make our story stronger. We will add error bars in future revisions.

## Reviewer 5:

### 1. What is the overhead of Lua?

The overhead of Mantle is the graph between the 1 MDS curve (red) and the MDS0 curve in Figure 10. 

### 2. Why can`t the balancer decide how much load to send? How does Mantle handle thrashing?

The original balancer does indeed decide how much to send, but it uses one heuristic (biggest first) to send off directory fragments. These bad choices lead to oscillation/thrashing, so Mantle uses multiple heuristics and chooses the one that gets closes to the target load.

### 3. Clarification questions about the graphs and Mantle's architecture

We apologize that the descriptions weren't clear and will work to address these in future revisions.
