We thank the reviewers for their time and thoughtful suggestions.

# General questions

### 1. Why do we report a limited number of workloads and are these workloads representative of many HPC applications?
- reviewer 1, 2, 4

We present in-depth profiles (throughput curves over time) of 3 Mantle balancers (along with slight tweaks to the policies that bring the total number of policies to 6) for a smaller number of workloads to give a more comprehensive view of how load is split across MDS nodes. Since our contribution is a general framework for testing and specifying different balancing scripts, we felt that space was better utilized by showing how the balancer can achieve multiple balancers on the same storage system, instead of drawing broad conclusion about which balancers are best for a given workload - this is future work.

Checkpoint/restart, which is characterized by many, concurrent creates, is a common HPC paradigm. We use it as a benchmark, even though it is notoriously terrible for metadata services (as reviewer 4 notes) for 3 reasons: (1) it does a good job of stressing the system, (2) it has been exclusively studied in the most state-of-the-art systems (e.g., GIGA+), and (3) it is a real problem (we will shore up our related work with more references to demonstrate this point). Compiling the Linux kernel is not as common, but we choose it because it exhibits a wider range of metadata requests types/frequencies and because users plan to use CephFS as a backup repository, a shared file system, and file server, and/or a compute backend (according to personal communication with Ceph developers and the mailing list).

### 2. How specific to CephFS are the results?
- reviewer 1, 4

The raw performance number are specific to CephFS, but Mantle generalizes the strategies of many systems by supporting the exploration of a wide range of balancing policies on the same storage system. The biggest flaw in our paper is not properly contextualizing how Mantle fits into the related work. We are not arguing that Mantle is more scalable or better performing than GIGA+. Instead, we use Mantle to highlight how locality can improve performance in a distributed file systems.

Future revisions of the paper will expand on Section 2.4 and Fig. 3, as the success of dynamic subtree partitioning is contingent on whether these factors are true. We will also expand on GIGA+ in the related work, becuse it was never our intention to "dismiss" GIGA+, rather, we want to highlight its strategy in comparison to other strategies using Mantle. While it is natural to compare raw performance numbers in an apples-to-apples way, we feel (and not just because GIGA+ outperforms Mantle) that we are attacking an orthogonal issue by providing a system for which we can test the strategies of the systems, rather than the systems themselves.

### 3. How does Mantle scale?
- reviewer 3, 4, 5

We agree that scalability is important. But please keep in mind that many parallel file systems deployed in today's production environments use a metadata service that is still limited to a very small number of nodes (less than 10, often less than 5). We found that our balancer in its current state is robust until about 20 nodes, at which point there is increased variability in the client's performance (as reviewer 3 notes) for reasons that we are still investigating. In the near term, 20 nodes should provide enough scalability in production environments. Our focus in this paper is to explore infrastructures for better understanding of how to balance diverse distributed metadata workloads as they might occur in real production environments (not just file create workloads), and ask the question "for a given workload, is it better (1) to immediately spread load aggressively or (2) to first understand the capacity of MDS nodes before splitting load at the right time under the right conditions?" We show how the second option can lead to better performance but at the cost of increased complexity. While we do not come up with a solution that is better than state-of-the-art systems optimized for file creates (e.g., GIGA+), we do present a framework that allows users to study the emergent behavior of different strategies, both in research and in the class room.

### 1. Can this technique be more sophisticated?
- reviewer 1, 4, 5
The actual technique, of separating the metadata policy from its mechanisms, is left intentionally simple, but lets the administrator layer more sophisticated balancers, with different metrics, statistical modeling, control feedback loops, or machine learning, on top is the intent. Mantle's ability to save state is a feature aimed at supporting such layers. One issue, as noted by reviewer 5, is that the current prototype doesn't stop the administrator from doing stupid things, like spawning a bunch of threads, using all the memory to write state, or injecting a "while 1". 

## Reviewer 1: 

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

### 2. What are the advantages of Mantle over a sharded key value store? If the answer is locality, I don't buy it.

Mantle lets us explore the benefits of locality and hashing. The intent of Figure 3 is to show how the number of requests affects performance. As you noted, this can be achieved with client side caching, but CephFS (as well as many other file systems) do not have that design, for a variety of reasons.

Rather t
The success of Mantle's dynamic subtree partitioning is contingent 
- reducing requests: figure 3
- lowering communication: ??
- memory pressure: caching inodes
TODO: 

### 6 What is the basic client-server metadata protocols? Is there a cost model

The last two bullets in Section 2.2 allude to the protocols but do a poor job of explaining them. Future versions will have a whole section devoted to it. As the reviewer notes, the papers are old and do not explain the protocols either, so for more information, see Sage's thesis and the code, which is open source. To answer your questions: 

MDS/Client interaction: MDS nodes and clients cache a configurable number of inodes. For creates, the client will issue a getattr, lookup, and create. Before reaching out to the MDS, the client will try to resolve the getattr and lookup locally (not the create itself like proposed in batchFS). The MDS nodes maintain the subtree boundaries and redirect requests to the "authority" MDS if a client's request falls outside of its jurisdiction. As the client receives responses, it builds up its own mapping of the namespace subtrees to MDS nodes.

Permissions: the MDS alters flags (saved in the directory as a state machine) to control writes and reads permissions. For coherency, MDSs will do a scatter-gather process, which has each MDS halt updates on a directory, send stats around the cluster, and then wait for the authoritative MDS to send back new data. These are done inside sessions (discussed in Section 5.1.1), which drag down our performance and leads to the less than desirable 18% slowdown from 1 MDS to 2 MDSs. 

### 7. How do you know that the load is saturating the system? How does the system scale?

Our experiments 
- is there problems with many MDSs and cold files (collective memory of MDSs)?
- the scalability story is not strong
    - we show that you do not need x MDSs to do a job that doesn't require it
- many many more questions

### 8. Why do we compare against running a single client running a single make?

We agree that 1 client compiling with 1 MDS isn't interesting, but the point of Figure 9 is that Mantle can spread metadata across the MDSs in different ways. The interesting result is 3 clients don't saturate the system enough to make distribution worthwhile and that 5 clients with 3 MDSs is just as efficient as 4 or 5 clients.

### 10. How does the MDS forward work? Why is there so much overhead?

Forwards happen when a client requests metadata that the MDS doesn't have. The MDS forwards the request to the correct MDS and the client updates its cache so that it will contact the correct MDS in the future. If the subtrees are partitioned poorly across the MDS nodes (e.g., the root inode is on MDS1 and the rest are on MDS2), then path traversals incurr many forwards. 

### 11. Why does reproducibility prevent us from using error bars?

You are correct, this will make our story stronger. We will add error bars in future revisions.

## Reviewer 5:

### 1. What is the overhead of Lua?

The overhead of Mantle is the graph between the 1 MDS curve (red) and the MDS0 curve in Figure 10. 

### 2. Why can`t the balancer decide how much load to send? How does Mantle handle thrashing?

The original balancer does indeed decide how much to send, but it uses one heuristic (biggest first) to send off directory fragments. These bad choices lead to oscillation/thrashing, so Mantle uses multiple heuristics and chooses the one that gets closes to the target load.

### 3. Clarification questions about the graphs and Mantle's architecture

We apologize that the descriptions weren't clear and will work to address these in future revisions.

- biggest issues: scalability, locality, contributions
