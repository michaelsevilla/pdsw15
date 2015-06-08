We thank the reviewers for their time and thoughtful suggestions.

# Reviewer 1: "Nevertheless, the paper is good and will be of interest to the community."

> 1) How linked to CephFS is this system?

2) Can this technique be more sophisticated?

3) Why didn't we use different kinds of loads (instead of just creates in separate directories)?

Reviewer 2: "The paper's well written." 
Weak accept

1) Is compiling Linux and creating a bunch of files in a directory representative of supercomputing loads? Why isn't there a suit of file-intensive scientific laods?

2) What are the contributions? If the contribution is the effect that policies have on behavior, then there needs to be a more comprehensive set of workloads.

Other comments: 
- CephFS doesn't have hysteresis?
- Typos

Reviewer 3:
- presentation: Sections 2-3 are too long are background; Fig. 3 has terms not described in the section.

1) Can I trust the metrics that Mantle uses, especially, since the effects on system as a whole has such had variability?

2) How representative is our small test system? Does variability increase with more clients?

3) What empirical observations/tests helped us arrive at the heuristics in the paper?

Reviewer 4: probably Garth Gibson
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




Reviewer 5: "This is an interesting paper of good quality; Regardless, here are some suggestions for small improvemtns:"
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

