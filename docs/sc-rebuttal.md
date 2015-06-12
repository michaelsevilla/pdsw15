We thank the reviewers for their hard work, attentiveness, and their genuinely helpful suggestions. 

#General questions

###1. Why is there a limited number of workloads? Are they representative of HPC? (reviewer 1,2,4)

We evaluate 3 balancers for less workloads to show a comprehensive view of how load splits across MDSs, but in future work we hope to draw conclusions about which balancers are best for a given workload. We use create workloads because they stress the system, are the focus of other state-of-the-art metadata systems, and they are a common HPC problem (checkpoint/restart). We use compiling code as the other workload because it has different metadata request types/frequencies and because users plan to use CephFS as a shared file system [1].

###2. How does Mantle scale? Are results specific to CephFS? (reviewer 3,4,5)

Scalability is important, but file systems deployed in today's production systems use metadata services with a small number of nodes (often less than 5) [1]. Our balancers are robust until 20 nodes, at which point there is increased variability in client performance (as reviewer 3 predicted) for reasons that we are still investigating. In future work focused on scalability, we expect to encounter problems with CephFS's architecture (e.g., n-way communication and memory pressure with many files), but we are optimistic that we can try other techniques using Mantle, like GIGA+'s autonomous load splitting, because each MDS independently makes decisions. Mantle has already exposed 2 performance deficiencies in CephFS, so it can also help improve metadata protocols and system architectures (Mantle is being pulled into Ceph).

In this paper, we explore infrastructures for better understanding of how to balance diverse metadata workloads and ask the question "is it better to spread load aggressively or to first understand the capacity of MDSs before splitting load at the right time under the right conditions?". Performance numbers are specific to CephFS, but our contribution is the balancing API/framework that allows users to study the emergent behavior of different strategies on the same storage system.

We never meant to "dismiss" GIGA+ or argue that Mantle is more scalable or better performing. We try to highlight its strategy in comparison to other strategies using Mantle. Future revisions will do a better job of placing Mantle in relation to related work. 

###3. Can techniques be more sophisticated? (reviewer 1,4,5)

For future work, we will layer complex balancers on top of Mantle. Mantle's ability to save state should accommodate balancers that use request cost modeling (noted by reviewer 4), statistical modeling, control feedback loops, and machine learning.

#Detailed feedback

##Reviewer 2: 

###1. Separating policy/mechanism isn't a contribution!

While this is a standard technique, applying it to a new problem can still be novel, particularly where nobody previously realized they were separable or has tried to separate them. Regardless of whether this convinces you, we hope that you agree that our response to general question 2 is the main contribution.

##Reviewer 3:

###1. Can I trust metrics that Mantle uses since their effects have high variability?

Mantle exposes many metrics that users can freely explore. Figuring out which metrics are important is a great use-case for Mantle.

###2. What empirical observations helped us arrive at heuristics in the paper?

Revised versions will condense Sections 2/3 and will make it clear that the heuristics are strategies from related work (GIGA+, LARD, original CephFS).

##Reviewer 4:

This feedback is exceptional and we'd welcome an opportunity to openly discuss all the issues raised (without a word count limit). We feel that the discussions would benefit both IndexFS/GIGA+ and CephFS.

###1. What are the metadata protocols?

[3] and the Ceph code (open source) have details, but future versions of the paper will explain the following: MDSs/clients cache inodes, so clients will try to resolve getattr/lookups locally. MDSs maintain their own subtree boundaries and "forward" requests for other subtrees to the "authority" MDS. Clients build mappings of subtrees to MDSs as they receive responses. For coherency, MDSs do a scatter-gather process (many messages for statistics/deltas) and maintain sessions with clients (Section 5.1.1). These overheads cause the 18% slowdown from 1 MDS to 2 MDSs.

###2. Complexity outweighs locality benefits.

Locality arguments are in [2], but future revisions will clarify: reducing requests refers to "forwards" between MDSs (Figure 3); lowering communication refers to messages for coherency (reflects system design); and memory pressure refers to space for caching parent inodes used for path traversal (distribution replicates inodes).

References: [1] personal communication with Ceph users/developers; [2] Weil et al. SC'04; [3] Weil PhD Thesis
