We thank the reviewers for their time and thoughtful suggestions.

# General questions
###1. Why is there a limited number of workloads? Are they representative of HPC?
(reviewer 1,2,4)

We evaluate 3 balancers for less workloads to show a comprehensive view of how load splits across MDSs, but in future work, we hope to draw conclusions about which balancers are best for a given workload. We use create workloads because they stress the system, are the focus of other state-of-the-art metadata systems, and they are a common HPC problem (checkpoint/restart). We use compiling code as the other workload because it has different metadata request types/frequencies and because users plan to use CephFS as a shared file system [1].

###2. How does Mantle scale? Are results specific to CephFS?
(reviewer 3,4,5)

Scalability is important, but please keep in mind that many file systems deployed in today's production systems use metadata services with a small number of nodes (less than 10, often less than 5) [1]. Our balancer in its current state is robust until 20 nodes, at which point there is increased variability in the client's performance (as reviewer 3 predicted) for reasons that we are still investigating. A deeper scalability analysis is future work and we expect to encounter many interesting problems with CephFS's architecture (e.g., memory pressure and n-way communication as noted by reviewer 4).

In this paper, we explore infrastructures for better understanding of how to balance diverse metadata workloads as they might occur in real production environments and ask the question "for a given workload, is it better to spread load aggressively or to first understand the capacity of MDSs before splitting load at the right time under the right conditions?". Performance numbers are specific to CephFS, but our contribution is the balancing API and framework that allows users to study the emergent behavior of different strategies on the same storage system.

We never meant to "dismiss" GIGA+ or argue that Mantle is more scalable or better performing. We try to highlight its strategy in comparison to other strategies using Mantle. Future revisions will do a better job of placing Mantle in relation to related work. 

###3. Can this technique be more sophisticated?
(reviewer 1,4,5)

For future work, we will layer complex balancers on top of Mantle. Mantle's ability to save state is a feature aimed at supporting request cost modeling (noted by reviewer 4), statistical modeling, control feedback loops, and machine learning techniques. 


# Detailed feedback
##Reviewer 2: 
###1. Separating policy/mechanism isn't a contribution!

While this is a standard technique, applying it to a new problem can still be novel, particularly where nobody previously realized they were separable or has tried to separate them. Regardless of whether this convinces you, please focus on the response to general question 2 for the main contribution.

##Reviewer 3:
###1. Can I trust the metrics that Mantle uses since their effects have high variability?

Mantle pulls out metrics that could be important so that the administrator can freely explore them. Figuring out which metrics are important is a great use-case.

###2. What empirical observations helped us arrive at the heuristics in the paper?

Revised version will condense Sections 2/3 and will make it clear that the heuristics are strategies from related work (GIGA+, LARD, original CephFS).

##Reviewer 4:
This feedback is exceptional and we'd welcome an opportunity to openly discuss (without a wordcount limit) ALL the issues raised. We feel the discussions would benefit both GIGA+ and CephFS.

###1. Complexity outweighs locality benefits.

Locality arguments are made in [2], but future revisions of the paper will clarify:
- reducing requests: "forwards" between MDSs (Figure 3). 
- lowering communication: the messages for coherency (yes, it is arhitectural)
- memory pressure: space for caching parent inodes used for path traversal. Distribution replicates inodes.

###2. What are the client-server metadata protocols?

[3] and the Ceph code (open source) have more details, but future versions of the paper will explain the following: 

MDSs/clients cache inodes, so the client will try to resolve the getattr/lookups locally. MDSs maintain the subtree boundaries and "forwards" requests for other subtrees to the "authority" MDS. Clients build their own mappings of the subtrees to MDSs as they receive responses. For coherency, MDSs do a scatter-gather process which has overhead (many messages for stats/deltas). MDSs and clients maintain sessions (Section 5.1.1), which also has overhead leading to the 18% slowdown from 1 MDS to 2 MDSs.

[1] personal communcation over the mailing list
[2] SC paper
[3] Sage's thesis
