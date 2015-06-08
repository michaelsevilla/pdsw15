
We thank the reviewers for their time and thoughtful suggestions.

# General questions

> Why do we report a limited number of workloads?
> - reviewer 1, 2

One of our contributions is a general framework for supporting different balancing scripts, so our results focus on showing how the balancers change the behavior of the system instead of raw performance. We present profiles of the instantaneous throughput for a small number of experiments to show how Mantle alters the system’s behavior. Since our contribution is showing the benefits of locality and the balancer API itself, we felt that the space we had was better utilized showing how the balancer can achieve multiple balancers on the same storage system.

We choose workloads that both stress the system and are representative of supercomputing; these are in no way complete or comprehensive. Checkpoint/restart, which is characterized by many, concurrent creates, is a common paradigm and has been exclusively studied in the most state-of-the-art systems (e.g., GIGA+). Compiling the Linux kernel is not as common in supercomputing, but we choose it because talks with talks with the Ceph developers, and the mailing list, indicate that the community is planning to use CephFS as a backup repository, a shared file system, a file server, and/or a compute backend. We choose it because it exhibits a wider range of metadata requests types and frequencies.


> How specific to CephFS are the results?
> - reviewer 1

The raw performance number are specific to CephFS, but the flexibility of Mantle generalizes the results in two ways: (1) it lets us test a wide range of balancing policies on the same storage system, and (2) it shows that our techinque, of using hooks to separate policy from mechanism, could work for other systems.

> How does Mantle scale?
> - reviewer 3

We do not present scalability results in the paper, but the system will scale with the number of servers but the balancer gets more finicky the more MDSs that get added (this statement is anecdotal). While we agree that scalability is important, we stress that our conclusions stress efficiency: is it better to immediately spread load aggressively or to understand the capacity of your MDS to split load at the right time under the right conditions. The latter argument is more appealing but has more complexity and this paper tries to demonstrate the benefits of such an approach. While we do not come up with an architecture that works well for many types of workloads and better than the state of the art (GIGA+), we do present a framework that looks at these factors from a different angle and gives rise to a system that can explore these different strategies in a holistic way.


## Reviewer 1: 

> 1. How linked to CephFS is this system?
above

> 2. Can this technique be more sophisticated?
The actual technique, of separating the metadata policy from its mechanisms, is left intentionally simple, but lets the administrator layer more sophisticated balancers, with different metrics, statistical modeling, or machine learning, on top is the intent.

> 3. Why didn`t  we use different kinds of loads (instead of just creates in separate directories)?
above

### Positives
"Nevertheless, the paper is good and will be of interest to the community."

## Reviewer 2: 

> 1. Is compiling Linux and creating a bunch of files in a directory representative of supercomputing loads? Why isn`t there a suit of file-intensive scientific laods?

above

> 2. What are the contributions? If the contribution is the effect that policies have on behavior, then there needs to be a more comprehensive set of workloads.

Although we strive to quantify the effect that policies have on behavior, in this paper, we are only able to show that policies have a discernable affect on performance. Rather than presenting a suite of workloads that must be introduced, characterized, and implemented, we present a narrow set of workloads that show . Of course, running a suite of workloads over Mantle is future work. The novelty of our system is that it can provide a gneeral framework for expressing and testing a range of balancing techinque, while minimizing the overhead of porting the balancer to different systems

### Other comments: 
- CephFS doesn`t have hysteresis?
- Typos

### Positives
- "The paper's well written... Weak accept" 

## Reviewer 3:

> 1. Can I trust the metrics that Mantle uses, especially, since the effects on system as a whole has such had variability?

Finding the metrics that reflect the system`s state is one of the main use cases for Mantle! Mantle pulls out ALL the metrics that could be important (i.e. ones that we think, based on empirical evidence, are important) so that the adminsistrator can freely explore them. Unfortunately, if we need a metric that Mantle doesn`t expose, we nee d to open up CephFS and add it - but this overhead isn`t any worse than what we`d have to do with plain old CephFS. For example, one of the metrics that we started with was a running average of the CPU utilization, but we deteremined that this is insufficient for flash crowds, so we had to modify Mantle to expose the instantaneous CPU utilization. 

2) How representative is our small test system? Does variability increase with more clients?
above

3) What empirical observations/tests helped us arrive at the heuristics in the paper?

The heuristics we explore are from related work. Spill evenly is from GIGA+, Spill and Fill is a variation of LARD (we actually didn`t see this paper until recently, but it will cited in the final version), and the Adaptable balancer is the original CephFS balancer policy. We find thresholds for the spill and fill technique using the latency vs. throughput graph in Fig. 5, but for the most part, these heuristics are just starting points for showing the power of Mantle and we are not ready to make grandiose statements about which is best... yet.

### Other comments
- presentation: Sections 2-3 are too long are background
- Fig. 3 has terms not described in the section.

## Reviewer 4: probably Garth Gibson
Typos:
- objective clause 

1) How specific to CephFS are the results?

2) Is the complexity and poor behavior arguments AGAINST the use of dynamic subtree partitioning? 

3) Why did you choose the creates, one of the worst workloads?

4) What are the advantages of Mantle over a sharded key value store?

5) What are the benevits of locality?
- combat his critique of reducing requests, lowering communication, memory pressure

6) What is the basic client-server metadata protocols? 
- e.g., why does a single client run 18% slower on 2 MDSs


3) How do you know that the load is saturating the system? How does the system scale?
- is there problems with many MDSs and cold files (collective memory of MDSs)?
- the scalability story is not strong
    - we show that you don't need x MDSs to do a job that doesn't require it
- many many more questions

7) Why do we compare against running a single client running a single make?

4) What are the details of the metadata protocols and is there a cost model of MDS operations?

8) How does the MDS forward work? Why is there so much overhead?

9) Why does reproducibility prevent us from using error bards?

10) What about control (such as, I don't want that load) or feedback loop?

11) Figure 7: difference between fill and spill and spill evenly




## Reviewer 5: "This is an interesting paper of good quality; Regardless, here are some suggestions for small improvemtns:"
- Section 3.2: the workload will also affect global state view (unsolved problem)
Presentation
- Vertical gridlines in Figure 4/7
- Whitespace in big_first before section 5 using inline

1) What is the overhead of Lua?

2) What can be saved in the balancer states across decisions? Will any resources (e.g., memory) limit how much state we can save?

3) How do you protect the designer from making mistakes (e.g., creating a separate thread or using unlimited memory)?

4) Can you compare this evaluation in to some real world CephFS deployments?

5) How are directory counters tracked over time/aged?

6) Are the times in Figure 3 the total times? What is the difference between high locality and good balance - doesn't using a single MDS lead to the best performance?

7) Does Mantle and the old CephFS  run on every MDS concurrently?

8) How does Mantle handle oscillation/thrashing?

9) Why can't the balancer decide how much load to send?
- it can, it just chooses... poorly

