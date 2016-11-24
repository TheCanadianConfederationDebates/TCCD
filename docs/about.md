# Project Description

This project, which has a web presence at http://www.theconfederationdebates.ca/, aims to digitize all of the legislative debates (provindial and federal) as well as treaty negotiations which are pertinent to confederation in Canada. This document describes the project's procedures and the organization of data and code.

## Data Creation and Organization
### Initial OCR
Page images from legislative records are the main primary source for the project. For some legislatures, official records do not exist, so contemporary newspaper reports are used. Page images have been obtained from various sources. We start from the images. All data is initially stored in the project's `data` folder, organized initially like this:

* data
  * Province
    * Provincial
        * `images`
        * `hocr_orig`
        * `hocr`
        * `hocr_edited`
        * `pdf`
    * Federal
      *\[...\]
      
When page-images are created, they are added to the `images` folder. Then [Tesseract] (https://github.com/tesseract-ocr) is used to do OCR, controlled by [Apache Ant] (http://ant.apache.org/); the build file is `code/scan_folder.xml`. This generates HOCR files; these are the results of the OCR process, encoded in a particular flavour of XHTML. These files are stored in `hocr_orig`. Following that, a subsequent transformation also invoked by the Ant script transforms and cleans up these files using Saxon and the XSLT file `code/xslt/enhance_hocr_bulk.xsl`. These files are stored in the folder `hocr`. Also, as part of the OCR process, text-over-image PDFs are created for each of the pages. These are used for convenient searching of the uncorrected OCR data; they will eventually be discarded.

### OCR Proofing/Correction
Correction takes place in two different ways:
#### Manual correction of XHTML
Some volunteers do manual correction of the XHTML code using the Kompozer application. This approach was most common early in the project, and has now largely been abandoned.
#### Online correction through the Transcriber Portal
Most correction now takes place through the [Transcriber Portal] (http://transcribe.theconfederationdebates.ca/), which provides a WYSIWYG interface for volunteers. Processed HOCR pages and images are copied from the GitHub repository into the portal for transcribers to work on them.

### Reintegration of corrected data
Corrected documents, still consisting of one document per page, are reintegrated into the GitHub dataset in the `hocr_edited` folder.

### Creation of TEI XML
One significant problem we have is that the original image filenames, and the resulting OCR files, are not named in a rigorous way to specify their source and actual page number. In addition, the output produced by the Transcriber Portal is in the form of files with essentially random numbers in their names. Finally, the corrected data has one document per page.

Our project administrators undertake an organization process that works like this:

  * Page-images are renamed in a meaningful way. The results are stored in the `final/images` folder.
  * HOCR files are renamed to match page-image names
  * TEI files are created (from the template `data/templates/debate.xml` for each individual debate (or part of a debate which covers confederation) for a single day. These files link to the page-images and HOCR files which comprise the contents of that debate. Appropriate metadata is supplied for the file.
  * These TEI files are processed using `code/xslt/hocr_to_tei.xsl`; in that process, the transcription contents are imported from the corrected HOCR files, creating a TEI file comprising a series of pages.
  * The project admins work through this file, fixing problems and ensuring that page-breaks and image links are correct.
  * These TEI files are stored in the root folder for the legislature concerned (e.g. `data/BC/Provincial`).

### Markup of Names
One objective of this project is to allow anyone to discover what any representative of a particular riding or area said on the subject of confederation; for that reason, we need to tag the names of all speakers in the debates, and link them to information in a personography, and thence to a specific riding or location.

