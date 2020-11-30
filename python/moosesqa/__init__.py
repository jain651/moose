"""Python utilities for performing SQA related checks"""
from .SilentRecordHandler import SilentRecordHandler
import logging
logger = logging.getLogger('moosesqa')
logger.addHandler(SilentRecordHandler())

from .get_sqa_reports import get_sqa_reports
from .check_syntax import check_syntax, file_is_stub, find_md_file
from .get_requirements import get_requirements
from .check_requirements import check_requirements
from .SQAReport import SQAReport
from .SQADocumentReport import SQADocumentReport
from .SQARequirementReport import SQARequirementReport, SQARequirementDiffReport
from .SQAMooseAppReport import SQAMooseAppReport
from .Requirement import Requirement, Detail, TestSpecification
from .LogHelper import LogHelper

MOOSESQA_COLLECTIONS = dict()
MOOSESQA_COLLECTIONS['FAILURE_ANALYSIS'] = "Requirements that perform check for simulation " \
                                           "integrity such as error handling and convergence " \
                                           "failures."
