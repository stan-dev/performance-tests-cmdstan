def MapBuildResult(body){
    returnMap = [:]

    benchmarks = (body =~ /\/benchmarks\/(\w+)\/(.*?)', (.*?), (.*?), (.*?), (.*?)\)/)
    compilation = (body =~ /compilation', (.*?), (.*?), (.*?), (.*?)\)/)[0][1]
    mean = (body =~ /(?s)(\d{1}\.?\d{11})/)[0][1]

    println benchmarks.size()

    for (i = 0; i < benchmarks.size(); i++) {
      name = benchmarks[i][1]
      filename = benchmarks[i][2]
      old_value = benchmarks[i][3]
      new_value = benchmarks[i][4]
      ratio = benchmarks[i][5]
      change = benchmarks[i][6]

      returnMap["$name"] = [
        "old": old_value,
        "new": new_value,
        "ratio": ratio,
        "change": change
      ]
    }

    returnMap["compilation"] = compilation.toString()
    returnMap["mean"] = mean.toString()
    
    return returnMap
}

def MapLastGitHubComment(body){
    returnMap = [:]

    benchmarks = (body =~ /\| (.*?) \| (.*?) \|/)

    for (i = 0; i < benchmarks.size(); i++) {
      name = benchmarks[i][1]
      value = benchmarks[i][2]

      if(name != "Name") 
        returnMap[name] = value
    }

    return returnMap
}

def aaa = """
('stat_comp_benchmarks/benchmarks/gp_pois_regr/gp_pois_regr.stan', 1.06)
('stat_comp_benchmarks/benchmarks/low_dim_corr_gauss/low_dim_corr_gauss.stan', 0.97)
('stat_comp_benchmarks/benchmarks/eight_schools/eight_schools.stan', 0.98)
('stat_comp_benchmarks/benchmarks/irt_2pl/irt_2pl.stan', 1.01)
('compilation', 1.08)
('stat_comp_benchmarks/benchmarks/gp_regr/gp_regr.stan', 1.0)
('stat_comp_benchmarks/benchmarks/low_dim_gauss_mix_collapse/low_dim_gauss_mix_collapse.stan', 1.0)
('stat_comp_benchmarks/benchmarks/pkpd/one_comp_mm_elim_abs.stan', 0.98)
('stat_comp_benchmarks/benchmarks/sir/sir.stan', 1.03)
('stat_comp_benchmarks/benchmarks/pkpd/sim_one_comp_mm_elim_abs.stan', 1.03)
('stat_comp_benchmarks/benchmarks/garch/garch.stan', 1.0)
('stat_comp_benchmarks/benchmarks/gp_regr/gen_gp_data.stan', 1.0)
('stat_comp_benchmarks/benchmarks/arK/arK.stan', 1.0)
('stat_comp_benchmarks/benchmarks/arma/arma.stan', 1.0)
('stat_comp_benchmarks/benchmarks/low_dim_gauss_mix/low_dim_gauss_mix.stan', 1.0)
1.00884324567
"""

def bbb = """
[Jenkins Console Log](https://jenkins.mc-stan.org/job/stan/view/change-requests/job/PR-2761/54/consoleFull)
[Blue Ocean](https://jenkins.mc-stan.org/blue/organizations/jenkins/stan/detail/PR-2761/54/pipeline)
- - - - - - - - - - - - - - - - - - - - -
| Name | Result |
| ------------- |------------- |
| gp_pois_regr | 1.06 |
| low_dim_corr_gauss | 0.97 |
| irt_2pl | 1.01 |
| one_comp_mm_elim_abs | 0.98 |
| eight_schools | 0.98 |
| gp_regr | 1.0 |
| arK | 1.0 |
| compilation | 1.08 |
| low_dim_gauss_mix_collapse | 1.0 |
| low_dim_gauss_mix | 1.0 |
| sir | 1.03 |
| sim_one_comp_mm_elim_abs | 1.03 |
| garch | 1.0 |
| gen_gp_data | 1.0 |
| arma | 1.0 |
| result | 1.00884381395 |
"""
println MapBuildResult(aaa).size()
println MapLastGitHubComment(bbb).size()

//def res = results_to_obj(bbb, "old")
//res.properties.each { println "$it.key -> $it.value" }