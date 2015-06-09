We thank the reviewers for their time and thoughtful suggestions.

# General questions
- biggest issues: scalability, locality, contributions

### 1. Why do we report a limited number of workloads and are these workloads representative of many HPC applications?

We present in-depth profiles (throughput curves over time) of 3 Mantle balancers (along with slight tweaks to the policies that bring the total number of policies to 6) for a smaller number of workloads to give a more comprehensive view of how load is split across MDS nodes. Since our contribution is a general framework for testing and specifying different balancing scripts, we felt that space was better utilized by showing how the balancer can achieve multiple balancers on the same storage system, instead of drawing broad conclusion about which balancers are best for a given workload - this is future work.

Checkpoint/restart, which is characterized by many, concurrent creates, is a common HPC paradigm. We use it as a benchmark, even though it is notoriously terrible for metadata services (as reviewer 4 notes) for 3 reasons: (1) it does a good job of stressing the system, (2) it has been exclusively studied in the most state-of-the-art systems (e.g., GIGA+), and (3) it is a real problem (we will shore up our related work with more references to demonstrate this point). Compiling the Linux kernel is not as common, but we choose it because it exhibits a wider range of metadata requests types/frequencies and because users plan to use CephFS as a backup repository, a shared file system, and file server, and/or a compute backend (according to personal communication with Ceph developers and the mailing list).

### 2. How specific to CephFS are the results?

The raw performance number are specific to CephFS, but Mantle generalizes the stratgies of many systems by supporting the exploration of a wide range of balancing policies on the same storage system. The biggest flaw in our paper is not properly contextualizing how Mantle fits into the related work. We are not arguing that Mantle is more scalable or better performing than GIGA+. Instead, we use Mantle to highlight how locality can improve performance in a distributed file systems. 

Future revisions of the paper will expand on Section 2.4 and Fig. 3, as the success of dynamic subtree partitioning is contingent on whether these factors are true. We will also expand on GIGA+ in the related work, becuse it was never our intention to "dismiss" GIGA+, rather, we want to highlight its strategy in comparison to other strategies using Mantle. While it is natural to compare raw performance numbers in an apples-to-apples way, we feel (and not just because GIGA+ outperforms Mantle) that we are attacking an orthogonal issue by providing a system that we can test the strategies of the systems, rather than the systems themselves.

### 3. How does Mantle scale?

The system will scale with the number of servers but the balancer gets more finicky the more MDSs that get added (this statement is anecdotal). While we agree that scalability is important, we stress that our conclusions stress efficiency: for a given workload, is it better to immediately spread load aggressively or to understand the capacity of your MDS to split load at the right time under the right conditions. We show how the second option is more appealing but acknowledge that it introduces significant complexity. While we do not come up with an architecture that is better than the state-of-the-art (e.g., GIGA+) or that works well for many workloads, we do present a framework that looks at these factors from a different angle and gives rise to a system that can explore these different strategies in a holistic way.

# Detailed Reviewer Questions
## Reviewer 1: 

### 1. How linked to CephFS is this system?

general question 2

### 2. Can this technique be more sophisticated?

The actual technique, of separating the metadata policy from its mechanisms, is left intentionally simple, but lets the administrator layer more sophisticated balancers, with different metrics, statistical modeling, control feedback loops, or machine learning, on top is the intent.

### 3. Why did we focus on just creates in separate directories instead of a different kinds of loads?

general question 1

## Reviewer 2: 

### 1. Is compiling Linux and creating a bunch of files in a directory representative of supercomputing loads? there a suite of file-intensive scientific loads?

general question 1

### 2. What are the contributions? If the contribution is the effect that policies have on behavior, then there needs to be a more comprehensive set of workloads.

Although we strive to quantify the effect that policies on performance, in this paper we only show how certain policies can improve or degrade performance. We try to stay away from characterizing different workloads and finding balancers tailored to them and instead focus on the system itself. Of course, running a suite of workloads over Mantle is future work. The novelty of our system is that it can provide a gneeral framework for expressing and testing a range of balancing techinque, while minimizing the overhead of porting the balancer to different systems.

We agree that separating policy from mechanism is not a contribution, but a technique that has been used many times before. In future revisions, we will focus on the balancing API and the framework testing different strategies as our contributions.


## Reviewer 3:

### 1. Can I trust the metrics that Mantle uses, especially, since the effects on the system as a whole has such had variability?

Finding the metrics that reflect the systems state is one of the main use cases for Mantle! Mantle pulls out ALL the metrics that could be important (i.e. ones that we think, based on empirical evidence, are important) so that the adminsistrator can freely explore them. Unfortunately, if we need a metric that Mantle doesn't expose, we nee d to open up CephFS and add it - but this overhead isn't any worse than what we'd have to do with plain old CephFS. For example, one of the metrics that we started with was a running average of the CPU utilization, but we deteremined that this is insufficient for flash crowds, so we had to modify Mantle to expose the instantaneous CPU utilization. 

### 2. How representative is our small test system? Does variability increase with more clients?

general question 3

### 3. What empirical observations/tests helped us arrive at the heuristics in the paper?

The heuristics we explore are from related work. Spill evenly is from GIGA+, Spill and Fill is a variation of LARD (we actually didn't see this paper until recently, but it will cited in the final version), and the Adaptable balancer is the original CephFS balancer policy. We find thresholds for the spill and fill technique using the latency vs. throughput graph in Fig. 5, but for the most part, these heuristics are just starting points for showing the power of Mantle and we are not ready to make grandiose statements about which is best... yet. The revised version of the paper will condense the background sections (2 and 3) to make room for this explanation.

### Other comments
- Fig. 3 has terms not described in the section.

## Reviewer 4: probably Garth Gibson

### 1. How specific to CephFS are the results?

general quetion 2

### 2. Is the complexity and poor behavior arguments AGAINST the use of dynamic subtree partitioning? 

Yes, the paper spends too much time framing the complexity of dynamic subtree partitioning, but the takeaway should have been that  Mantle's flexibility is appealing and warrants exploration. In future versions of the paper, we will compress Section 3 and rename it "Dynamic Subtree Paritioning Challenges". 

### 3. Why did you choose creates, one of the worst workloads?

general question 1

### 4. What are the advantages of Mantle over a sharded key value store?

The flexibility to explore the benefits of locality (see 5) vs. hashing.

### 5. What are the benefits of locality?

The success of Mantle's dynamic subtree partitioning is contingent 
- reducing requests: figure 3
- lowering communication: ??
- memory pressure: caching inodes
TODO: 

### 6 What is the basic client-server metadata protocols? 
- e.g., why does a single client run 18% slower on 2 MDSs

TODO:

### 7. How do you know that the load is saturating the system? How does the system scale?

Our experiments 
- is there problems with many MDSs and cold files (collective memory of MDSs)?
- the scalability story is not strong
    - we show that you do not need x MDSs to do a job that doesn't require it
- many many more questions

### 8. Why do we compare against running a single client running a single make?

We agree that 1 client compiling with 1 MDS isn't interesting, but the point of Figure 9 is that Mantle can spread metadata across the MDSs in different ways. The interesting result is 3 clients don't saturate the system enough to make distribution worthwhile and that 5 clients with 3 MDSs is just as efficient as 4 or 5 clients.

### 9. What are the details of the metadata protocols and is there a cost model of MDS operations?

TODO:

### 10. How does the MDS forward work? Why is there so much overhead?

Forwards happen when a client requests metadata that the MDS doesn't have. The MDS forwards the request to the correct MDS and the client updates its cache so that it will contact the correct MDS in the future. If the subtrees are partitioned poorly across the MDS nodes (e.g., the root inode is on MDS1 and the rest are on MDS2), then path traversals incurr many forwards. 

### 11. Why does reproducibility prevent us from using error bars?

You are correct, this will make our story stronger. We will add error bars in future revisions.

### 12. What about control (such as, I don't want that load) or feedback loop?

general question 2 (also future work)

### 13. Figure 7: difference between fill and spill and spill evenly

TODO:

## Reviewer 5: "This is an interesting paper of good quality; Regardless, here are some suggestions for small improvemtns:"
- Section 3.2: the workload will also affect global state view (unsolved problem)
Presentation
- Vertical gridlines in Figure 4/7
- Whitespace in big_first before section 5 using inline

### 1. What is the overhead of Lua?

### 2. What can be saved in the balancer states across decisions? Will any resources (e.g., memory) limit how much state we can save?

### 3. How do you protect the designer from making mistakes (e.g., creating a separate thread or using unlimited memory)?

### 4. Can you compare this evaluation in to some real world CephFS deployments?

### 5. How are directory counters tracked over time/aged?

### 6. Are the times in Figure 3 the total times? What is the difference between high locality and good balance - doesn't using a single MDS lead to the best performance?

### 7. Does Mantle and the old CephFS  run on every MDS concurrently?

### 8. How does Mantle handle oscillation/thrashing?

### 9. Why can`t the balancer decide how much load to send?
- it can, it just chooses... poorly

