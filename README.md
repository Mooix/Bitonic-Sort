# Bitonic-Sort
Implementation of Bitonic Sort Parallel algorithm using CUDA framework

Bitonic sort is a comparison-based sorting algorithm that can be parallelized on a GPU. The algorithm works by repeatedly merging adjacent pairs of elements, first in a bitonic sequence and then in a sorted sequence. A bitonic sequence is a sequence of elements that is first increasing and then decreasing, or vice versa.

The parallelization of Bitonic sort is achieved by using threads to compare and swap pairs of elements in the sequence. Each thread is responsible for a pair of adjacent elements, and the threads are organized in a grid of blocks. The algorithm is performed recursively, with each pass of the algorithm doubling the size of the sub-sequences being sorted.
