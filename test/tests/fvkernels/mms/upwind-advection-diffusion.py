#!/usr/bin/env python3

import mms
df1 = mms.run_spatial('advection-diffusion.i', 7, "GlobalParams/advected_interp_method='upwind'")

fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
fig.plot(df1, label='upwind-adv-diff', marker='o', markersize=8, num_fitted_points=3, slope_precision=1)
fig.save('upwind-advection-diffusion.png')
