#
# Simple list append filter
#
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from jinja2 import TemplateError

class FilterModule(object):


#
# Append a number of items to the list
#
  def list_append(self,l,*argv):
    if type(l) is not list:
      raise TemplateError("First argument of append filter must be a list")

    for element in argv:
      if type(element) is list:
        l.extend(element)
      else:
        l.append(element)
    return l

  def list_flatten(self,l):
    if type(l) is not list:
      raise TemplateError("flatten filter takes a list")

    def recurse_flatten(l):
      if type(l) is not list:
        return [l]
      r = []
      for i in l:
        r.extend(recurse_flatten(i))
      return r

    return recurse_flatten(l)

  def check_duplicate_attr(self,d,attr = None,mandatory = False):
    seen = {}
    stat = []

    def get_value(value):

      def get_single_value(v,k):
        if not(k in v):
          if mandatory:
            raise TemplateError("Missing mandatory attribute %s in %s" % (k,v))
          else:
            return None
        return v[k]

      if type(attr) is list:
        retval = ""
        for a in attr:
          item = get_single_value(value,a)
          retval += " " if retval else ""
          retval += "%s=%s" % (a,item)
        return retval
      else:
        return get_single_value(value,attr)

    def check_unique_value(key,value):
      if key is not None:
        value['key'] = key
      v = get_value(value)
      if v in seen:
        stat.append("Duplicate value %s of attribute %s found in %s and %s" % 
            (v,attr,
             seen[v]['key'] if ('key' in seen[v]) else seen[v],
             value['key'] if ('key' in value) else value))
      else:
        seen[v] = value

    # sanity check: do we know which attribute to check?
    #
    if attr is None:
      raise TemplateError("You have to specify attr=name in checkunique")

    # iterate over a list or a dictionary, fail otherwise
    #
    if type(d) is list:
      for value in d:
        check_unique_value(None,value)
    elif type(d) is dict:
      for key in d:
        check_unique_value(key,d[key])
    else:
      raise TemplateError("")

    if len(stat) == 0:
      return None
    else:
      return stat

  def filters(self):
    return {
      'append': self.list_append,
      'flatten': self.list_flatten,
      'dupattr': self.check_duplicate_attr
    }