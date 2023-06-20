import os
import sys
import glob as glob
import subprocess as sp
import nibabel as nb
import glob as glob
sys.path.append('/bcbl/home/home_g-m/glerma/soft')
from PRFclass import PRF
from scipy.io import savemat
import numpy as np
from tqdm import tqdm

join = os.path.join

#%% for BCBL volume - surface comparison
codeP = '/bcbl/home/home_g-m/glerma/soft/prf2d3d'
baseP = '/bcbl/home/public/Gari'
projP = 'MINI/prfAnalysis'
pathMatlabFile = join(codeP, 'DATA', 'rmroicellOHBM.mat')
ans = ['01','02']  # ,'03']
# 01 is surface, 02 is orig volume analysis, 03 is resliced volume
os.chdir(join(baseP, projP,'derivatives','prfanalyze-vista','analysis-03'))
subjects = sorted(glob.glob('sub*'))

# S045 does not exist, remove it
subjects.pop(3)
subjects.pop(3)



sessions = ['ses-001','ses-002']
task = 'prf'
runs = ['01020304avg','01','02','03','04']
varExps = [.2,.1,.05]
# ROIS = [['V1','V2'],['V1','V2','V3']]
ROIS = ['V1','V2','V3']


# subject = subjects[0]
# an = ans[2]

session = sessions[0]
run = runs[0]
varExp = varExps[1]
# ROI = ROIS[0]
# print(f"\nTHIS TEST IS FOR: analysis-{an}_{subject}_{session}_{task}_{run}_varExp-{varExp}_ROI-{ROI}")


# for testing
# subjects = subjects[0:2]
# ROIS = ROIS[0:1]


# initialice
rmroicell = np.empty((len(subjects),len(ROIS),len(ans)), dtype=object)

for ROII, ROI in enumerate(ROIS):
    for subjectI, subject in enumerate(subjects):
        for anI, an in enumerate(ans):
            ana = PRF.from_docker(projP,subject,session,task,run,baseP=baseP,analysis=an)
            ana.maskROI(ROI)
            # ana.maskVarExp(varExp)

            # Create rmroiCell.mat
            # dim1: subjects, dim2: rois, dim3: dataType (words, checkers...)
            createStruct=  {"x0":ana.x,
                            "y0":ana.y,
                            "co":ana.varexp,
                            "name":ROI,
                            "sigma1":ana.s,
                            "sigma2":ana.s,
                            "vt":"Gray",
                            "sigma":ana.s,
                            "polar":ana.pol,
                            # "rawrss":ana._model["rawrss"],
                            # "rss":ana._model["rss"],
                            "ecc":ana.r,
                            "session":subject+an,
                            }
            rmroicell[subjectI, ROII, anI] = createStruct
savemat(pathMatlabFile, {"rmroiCell":rmroicell.tolist()})


#%% for VIE retcomp17 high - low res
codeP = '/z/fmrilab/home/dlinhardt/develop/prf2d3d'
baseP = '/ceph/mri.meduniwien.ac.at/projects/physics/fmri/data'
projP = 'retcomp17BIDS'
pathMatlabFile = join(codeP, 'DATA', 'rmroicell_HRLR.mat')
ans = ['02']
# 01 is resliced to anatomy space, 02 is individual space
subjects = sorted(glob.glob(join(baseP, projP,'derivatives','prfanalyze-vista','analysis-02','sub*')))
subjects = [os.path.basename(a) for a in subjects]

# S045 does not exist, remove it
# subjects.pop(8)
# subjects.pop(1)

sessions = ['ses-002','ses-001']
tasks = ['barHR','barLR']
runs = ['0102avg','01','02']
varExps = [.2,.1,.05]
ROIS = ['V1','V2','V3']

an = ans[0]
# session = sessions[0]
run = runs[0]
varExp = varExps[1]

# initialice
rmroicell = np.empty((len(subjects),len(ROIS),len(tasks)), dtype=object)

for ROII, ROI in enumerate(ROIS):
    for subjectI, subject in enumerate(subjects):
        for taskI, task in enumerate(tasks):
            ana = PRF.from_docker(projP,
                                  subject,
                                  sessions[taskI],
                                  task,
                                  run,
                                  baseP=baseP,
                                  analysis=an)
            ana.maskROI(ROI)

            # Create rmroiCell.mat
            # dim1: subjects, dim2: rois, dim3: dataType (words, checkers...)
            createStruct=  {"x0":ana.x,
                            "y0":ana.y,
                            "co":ana.varexp,
                            "name":ROI,
                            "sigma1":ana.s,
                            "sigma2":ana.s,
                            "vt":"Gray",
                            "sigma":ana.s,
                            "polar":ana.pol,
                            # "rawrss":ana._model["rawrss"],
                            # "rss":ana._model["rss"],
                            "ecc":ana.r,
                            "session":subject+an,
                            }
            rmroicell[subjectI, ROII, taskI] = createStruct
savemat(pathMatlabFile, {"rmroiCell":rmroicell.tolist()})



#%% for VIE mini vol surf comparison
codeP = '/z/fmrilab/home/dlinhardt/develop/prf2d3d'
baseP = '/ceph/mri.meduniwien.ac.at/projects/physics/fmri/data'
projP = 'mini_bcbl'
pathMatlabFile = join(codeP, 'DATA', 'rmroicell_mini_vol_surf_new.mat')
ans = ['surface','volume']
os.chdir(join(baseP, projP,'derivatives','prfanalyze-vista','analysis-surface'))
subjects = sorted(glob.glob('sub*'))

sessions = ['ses-001','ses-002']
task = 'prf'
runs = ['01020304avg','01','02','03','04']
varExps = [.2,.1,.05]
ROIS = ['V1','V2','V3']

session = sessions[0]
run = runs[0]
varExp = varExps[1]

# initialice
rmroicell = np.empty((len(subjects),len(ROIS),len(ans)), dtype=object)

for ROII, ROI in enumerate(ROIS):
    for subjectI, subject in enumerate(subjects):
        for anI, an in enumerate(ans):
            ana = PRF.from_docker(projP,subject,session,task,run,baseP=baseP,analysis=an)
            ana.maskROI(ROI)
            # ana.maskVarExp(varExp)

            # Create rmroiCell.mat
            # dim1: subjects, dim2: rois, dim3: dataType (words, checkers...)
            createStruct=  {"x0":ana.x,
                            "y0":ana.y,
                            "co":ana.varexp,
                            "name":ROI,
                            "sigma1":ana.s,
                            "sigma2":ana.s,
                            "vt":"Gray",
                            "sigma":ana.s,
                            "polar":ana.pol,
                            # "rawrss":ana._model["rawrss"],
                            # "rss":ana._model["rss"],
                            "ecc":ana.r,
                            "session":subject+an,
                            }
            rmroicell[subjectI, ROII, anI] = createStruct
savemat(pathMatlabFile, {"rmroiCell":rmroicell.tolist()})





#%% for VIE mini vol surf comparison only models in the data
codeP = '/z/fmrilab/home/dlinhardt/develop/prf2d3d'
baseP = '/ceph/mri.meduniwien.ac.at/projects/physics/fmri/data'
projP = 'mini_bcbl'
pathMatlabFile = join(codeP, 'DATA', 'rmroicell_mini_vol_surf_models.mat')
ans = ['06','07']
os.chdir(join(baseP, projP,'derivatives','prfanalyze-vista','analysis-surface'))
subjects = sorted(glob.glob('sub*'))

sessions = ['ses-001','ses-002']
task = 'prf'
runs = ['01020304avg','01','02','03','04']
varExps = [.2,.1,.05]
ROIS = ['V1','V2','V3']

session = sessions[0]
run = runs[0]
varExp = varExps[1]

# initialice
rmroicell = np.empty((len(subjects),len(ROIS),len(ans)), dtype=object)

pbar = tqdm(total=len(ROIS)*len(subjects)*len(ans))
for ROII, ROI in enumerate(ROIS):
    for subjectI, subject in enumerate(subjects):
        for anI, an in enumerate(ans):
            ana = PRF.from_docker(projP,
                                  subject,
                                  session,
                                  task,
                                  run,
                                  baseP=baseP,
                                  analysis=an)
            ana.maskROI(ROI)
            # ana.maskVarExp(varExp)

            # Create rmroiCell.mat
            # dim1: subjects, dim2: rois, dim3: dataType (words, checkers...)
            createStruct=  {"x0":ana.x,
                            "y0":ana.y,
                            "co":ana.varexp,
                            "name":ROI,
                            "sigma1":ana.s,
                            "sigma2":ana.s,
                            "vt":"Gray",
                            "sigma":ana.s,
                            "polar":ana.pol,
                            # "rawrss":ana._model["rawrss"],
                            # "rss":ana._model["rss"],
                            "ecc":ana.r,
                            "session":subject+an,
                            }
            rmroicell[subjectI, ROII, anI] = createStruct
            pbar.update(1)
pbar.close()

savemat(pathMatlabFile, {"rmroiCell":rmroicell.tolist()})




