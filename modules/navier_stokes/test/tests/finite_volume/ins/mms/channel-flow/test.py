import mms
import unittest
from mooseutils import fuzzyEqual, fuzzyAbsoluteEqual

class Test1DAverage(unittest.TestCase):
    def test(self):
        labels = ['L2u', 'L2p']
        df1 = mms.run_spatial('1d-average.i', 8, y_pp=labels)

        fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
        fig.plot(df1, label=labels, marker='o', markersize=8, num_fitted_points=3, slope_precision=1)
        fig.save('1d-average.png')
        for key,value in fig.label_to_slope.items():
            print("%s, %f" % (key, value))
            self.assertTrue(fuzzyAbsoluteEqual(value, 2., .05))

class Test1DRC(unittest.TestCase):
    def test(self):
        labels = ['L2u', 'L2p']
        df1 = mms.run_spatial('1d-rc.i', 8, y_pp=labels)

        fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
        fig.plot(df1, label=labels, marker='o', markersize=8, num_fitted_points=3, slope_precision=1)
        fig.save('1d-rc.png')
        for key,value in fig.label_to_slope.items():
            print("%s, %f" % (key, value))
            self.assertTrue(fuzzyAbsoluteEqual(value, 2., .05))

class Test2DAverage(unittest.TestCase):
    def test(self):
        labels = ['L2u', 'L2v', 'L2p']
        df1 = mms.run_spatial('2d-average.i', 6, y_pp=labels)

        fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
        fig.plot(df1, label=labels, marker='o', markersize=8, num_fitted_points=3, slope_precision=1)
        fig.save('2d-average.png')
        for key,value in fig.label_to_slope.items():
            print("%s, %f" % (key, value))
            self.assertTrue(fuzzyAbsoluteEqual(value, 2., .05))

class Test2DRC(unittest.TestCase):
    def test(self):
        labels = ['L2u', 'L2v', 'L2p']
        df1 = mms.run_spatial('2d-rc.i', 9, y_pp=labels, mpi=32)

        fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
        fig.plot(df1, label=labels, marker='o', markersize=8, num_fitted_points=3, slope_precision=1)
        fig.save('2d-rc.png')
        for key,value in fig.label_to_slope.items():
            print("%s, %f" % (key, value))
            self.assertTrue(fuzzyAbsoluteEqual(value, 2., .05))

class TestPlanePoiseuilleAverage(unittest.TestCase):
    def test(self):
        labels = ['L2u', 'L2v', 'L2p']
        df1 = mms.run_spatial('plane-poiseuille-flow.i', 6, "velocity_interp_method='average'", y_pp=labels, mpi=8)

        fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
        fig.plot(df1, label=labels, marker='o', markersize=8, num_fitted_points=3, slope_precision=1)
        fig.save('plane-poiseuille-average.png')
        for key,value in fig.label_to_slope.items():
            print("%s, %f" % (key, value))
            self.assertTrue(fuzzyAbsoluteEqual(value, 2., .05))

class TestPlanePoiseuilleRC(unittest.TestCase):
    def test(self):
        labels = ['L2u', 'L2v', 'L2p']
        df1 = mms.run_spatial('plane-poiseuille-flow.i', 6, "velocity_interp_method='rc'", y_pp=labels, mpi=8)

        fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
        fig.plot(df1, label=labels, marker='o', markersize=8, num_fitted_points=3, slope_precision=1)
        fig.save('plane-poiseuille-rc.png')
        for key,value in fig.label_to_slope.items():
            print("%s, %f" % (key, value))
            self.assertTrue(fuzzyAbsoluteEqual(value, 2., .05))

class TestPlanePoiseuilleAverageFirst(unittest.TestCase):
    def test(self):
        labels = ['L2u', 'L2v', 'L2p']
        df1 = mms.run_spatial('plane-poiseuille-flow.i', 7, "velocity_interp_method='average'", 'two_term_boundary_expansion=false', y_pp=labels, mpi=16)

        fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
        fig.plot(df1, label=labels, marker='o', markersize=8, num_fitted_points=3, slope_precision=1)
        fig.save('plane-poiseuille-average-first.png')
        for key,value in fig.label_to_slope.items():
            if key == 'L2p':
                self.assertTrue(fuzzyAbsoluteEqual(value, 1., .05))
            else:
                self.assertTrue(fuzzyAbsoluteEqual(value, 2., .05))

class TestPlanePoiseuilleRCFirst(unittest.TestCase):
    def test(self):
        labels = ['L2u', 'L2v', 'L2p']
        df1 = mms.run_spatial('plane-poiseuille-flow.i', 7, "velocity_interp_method='rc'", 'two_term_boundary_expansion=false', y_pp=labels, mpi=16)

        fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
        fig.plot(df1, label=labels, marker='o', markersize=8, num_fitted_points=3, slope_precision=1)
        fig.save('plane-poiseuille-rc-first.png')
        for key,value in fig.label_to_slope.items():
            print("%s, %f" % (key, value))
            self.assertTrue(fuzzyAbsoluteEqual(value, 2., .05))


class Test2DRCNoSlip(unittest.TestCase):
    def test(self):
        labels = ['L2u', 'L2v', 'L2p']
        df1 = mms.run_spatial('2d-rc-no-slip.i', 9, y_pp=labels, mpi=32)

        fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
        fig.plot(df1, label=labels, marker='o', markersize=8, num_fitted_points=3, slope_precision=1)
        fig.save('2d-rc-no-slip.png')
        for key,value in fig.label_to_slope.items():
            print("%s, %f" % (key, value))
            self.assertTrue(fuzzyAbsoluteEqual(value, 2., .05))

class Test2DAverageTemp(unittest.TestCase):
    def test(self):
        labels = ['L2u', 'L2v', 'L2p', 'L2t']
        df1 = mms.run_spatial('2d-average-with-temp.i', 6, y_pp=labels)

        fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
        fig.plot(df1, label=labels, marker='o', markersize=8, num_fitted_points=3, slope_precision=1)
        fig.save('2d-average-with-temp.png')
        for key,value in fig.label_to_slope.items():
            print("%s, %f" % (key, value))
            self.assertTrue(fuzzyAbsoluteEqual(value, 2., .05))

class Test2DRCTemp(unittest.TestCase):
    def test(self):
        labels = ['L2u', 'L2v', 'L2p', 'L2t']
        df1 = mms.run_spatial('2d-average-with-temp.i', 8, "velocity_interp_method='rc'", y_pp=labels, mpi=16)

        fig = mms.ConvergencePlot(xlabel='Element Size ($h$)', ylabel='$L_2$ Error')
        fig.plot(df1, label=labels, marker='o', markersize=8, num_fitted_points=3, slope_precision=1)
        fig.save('2d-rc-with-temp.png')
        for key,value in fig.label_to_slope.items():
            print("%s, %f" % (key, value))
            self.assertTrue(fuzzyAbsoluteEqual(value, 2., .1))

if __name__ == '__main__':
    unittest.main(__name__, verbosity=2)
