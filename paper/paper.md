---
title: 'resp_detect: Matlab tools for detecting breath events from DTAGs'
tags:
  - Matlab
  - DTAGs
  - breaths
  - whales
  - physiology
authors:
  - name: Ashley M. Blawas
    orcid: 0000-0003-4109-9003
    affiliation: 1
affiliations:
 - name: Nicholas School of the Environment, Duke University Marine Laboratory
   index: 1
date: 11 November 2020
bibliography: paper.bib

---

# Summary

Physiological investigations of free-swimming cetaceans have, historically, been limited because of the taxa's large body size and fully-aquatic lifestyle [@Block:2005; @Ponganis:2007; @Hooker:2007]. Although recent developments in digital bio-logging devices have enabled some direct measurements of physiological parameters in free-swimming cetaceans their use is still restricted because of the challenge both of physical device design and deployment [@Goldbogen:2019; @Williams:2017]. Respiratory parameters, including respiratory rate, are of particular interest in understanding the diving physiology of cetaceans because of their role in determining gas exchange and therefore the oxygen supply that supports breath-hold diving. Previous studies have determined respiratory rate of free-swimming cetaceans by direct observation [@Sumich:1983; @Blix:1995; @Williams:2009; @Christansen;2014], using the acoustic signal from tags equipped with hydrophones [@Goldbogen:2008], and from patterns in the pitch and depth signals from movement tags [@Miller:2010; @Roos:2016;, @Goldbogen:2008]). Although these methods are viable in some species, particularly those for which a one-to-one relationship between surfacing and breathing exists, they are not accurate for others that exhibit long periods of time at the surface with multiple breathing events, like short-finned pilot whales. The ability to measure physiological parameters in free-swimming cetaceans is crucial to inform our understanding how these species will be expected to respond to environmental change and the thresholds on their behavior. 


Here, we present ``resp_detect``, a set of Matlab tools to detect breathing events from high-resolution movement data recorded by digital acoustic recording tags (DTAGs). This novel method takes advantage of the high flow rates and large tidal volumes that are typical of cetacean breaths and detects the movement artifacts resulting from a breathing event. The library of functions associated with ``resp_detect`` allow a user to identify breaths across the tag record and export the timing of each breath. ``Resp_detect`` also provids users with tools to visualize breath detections with other dive parameters and validate breath detections with acoustic records. 

``Resp_detect`` is intended to be used with the existing DTAG processing tools developed by Mark Johnson. Theses tools require the same folder structure necessary for DTAG processing. A DTAG record should be processed through the step of exporting the ``prh.m`` file which contains the accelerometer and magentometer data transformed into the whale frame as well as the animal's pitch, roll, and heading. To use ``resp_detect`` tools, the user is first prompted to input the tag name (the prefix of the ``prh.mat`` file, i.e. gm08_143b). After identifying dives and calculating movement parameters, the user can run the breath detector which will identify all breaths taken in the tag record. Following detection, the tools allow the user to visualize the respiratory rate time series before exporting the timing of each breath, in addition to several other relevant dive parameters, in a `.mat` file. Additionally, the user can take advantage of several plotting tools to visualize the respiration data as it relates to other dive parameters. 

The ``resp_detect`` workflow also allows users to incorporate acoustic data into their analysis. Using the acoustic auditing tools made available in the existing DTAG Matlab tools users can mark acoustic breath detections and compare the timing of the breath detections from the movement sensors against the acoustic detections. This may be helpful in cases of uncertainty or to determine other respiratory variables when possible (i.e. duration of a breath or amplitude/dB of a breath). 

Currently, these tools are being used to detect breaths from DTAGs deployed on short-finned pilot whales, but there is the potential for these tools to be useful for any DTAG record. The best use cases for ``resp_detect`` are for DTAGs that were deployed proximal to the blowhole. If the tag is too far from the blowhole the movement of the breath may be dampened at the location of the tag.

# Figures

# Acknowledgements

I would like to acknowledge Dr. Douglas Nowacek and the Duke Superpod for project feedback and recommendations, Jeanne Shearer for pre-processing of the tag data used for beta testing.. This work was supported by the Duke University Marine Laboratory.

# References
