{smcl}
{* *! version 1.0.1  27oct2021}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "qdmean##syntax"}{...}
{viewerjumpto "Description" "qdmean##description"}{...}
{viewerjumpto "Options" "qdmean##options"}{...}
{viewerjumpto "Authors" "qdmean##authors"}{...}
{viewerjumpto "References" "qdmean##references"}
{viewerjumpto "Examples" "qdmean##examples"}{...}
{viewerjumpto "Version" "qdmean##version"}{...}

{title:Title}

{phang}
{bf:qdmean} {hline 2} A program to automatically quasi-demean regressors following a FGLS-RE or MLE-RE regression.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:qdmean} 
,[{cmdab:gen:erate(stub)}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Options}

{synopt:{opth gen:erate(stub)}}suffix to appear on generated quasi-demeaned variables{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:qdmean} is a program to automatically quasi-demean regressors following the estimation of a random effects (either using FGLS or maximum likelihood) model. This program requires you to first estimate a model using {cmd:xtreg}, with options {cmd:, re} or {cmd:, mle}. The program will automatically obtain theta_i and generate quasi-demeaned regressors, which are useful for post-estimation analysis. See Jordan and Philips (2021) for more details.

{pstd}
Users can find and download the most up-to-date version of {cmd:qdmean} at:
 http://andyphilips.github.io/REquasidemean/.
 
{marker options}{...}
{title:Options}
 
{phang}
{opth gen:erate(stub)} is a suffix to appear on generated quasi-demeaned variables. by default, all newly created variables contain the suffix "*_qdm".

{marker authors}{...}
{title:Authors}

{pstd}
Soren Jordan {break}
Department of Political Science {break}
Auburn University  {break}
sorenjordanpols@gmail.com {p_end}

{pstd}
Andrew Q. Philips {break}
Department of Political Science {break}
University of Colorado Boulder {break}
andrew.philips@colorado.edu {p_end}

{marker references}{...}
{title:References}

If you use {cmd:qdmean}, please cite:

{phang}Jordan, Soren and Andrew Q. Philips. 2021. "Improving the interpretation of random effects regression results." Working Paper: 1-19.{p_end}

{marker examples}{...}
{title:Examples}

{phang}Open up longitudinal dataset of women's wages:{p_end}
{phang}{cmd:webuse nlswork, clear}{p_end}
{phang}{cmd:xtset idcode year}{p_end}

{phang}Estimate RE-GLS model and quasi-demean regressors{p_end}

{phang}{cmd:xtreg ln_wage wks_work union age, re}{p_end}
{phang}{cmd:qdmean}{p_end}

{phang}RE-MLE and quasi-demean, with custom stub name{p_end}

{phang}{cmd:xtreg ln_wage wks_work union age, mle}{p_end}
{phang}{cmd:qdmean, generate(qvar)}{p_end}

{marker version}{...}
{title:Version}

version 1.0.1, Oct 27, 2021.

