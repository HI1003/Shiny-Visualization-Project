# Generic visualization examples and course scope. Exam content stays in the verified local bank.
learning_path_labels <- c("STATS125 Core"="core", "Optional STATS210 preview"="preview",
                         "Further exploration (optional)"="further")
learning_path <- function(value) {
  if (length(value)!=1L || is.na(value) || !value %in% c(unname(learning_path_labels),"legacy")) "core" else value
}
learning_path_label <- function(value) {
  if (identical(value,"legacy")) return("Original question library")
  names(learning_path_labels)[match(learning_path(value),learning_path_labels)]
}
learning_fraction <- function(n,d=1) {
  a<-abs(n);b<-abs(d)
  while(b!=0) {r<-a%%b;a<-b;b<-r}
  if(a==0) return("0")
  n<-n/a;d<-d/a
  if(d==1) as.character(n) else paste0(n,"/",d)
}
learning_math <- function(text) paste0("\\(",text,"\\)")
learning_counts <- function() matrix(c(6,4,2,8),nrow=2,byrow=TRUE)
learning_pmf_example <- function(key) {
  exam<-exam_pmf_example(key);if(!is.null(exam))return(exam)
  weights<-switch(key,cards=c(188,16,16,1),counts20=as.vector(t(learning_counts())),
                  zero_x=c(0,0,1,3),stop("Unknown worked example."))
  data.frame(x=c(0,0,1,1),y=c(0,1,0,1),p_input=as.character(weights),
             p_value=weights/sum(weights),id=1:4)
}
learning_pmf_notes <- c(
  cards="Two draws without replacement from 52 cards (4 Aces). X and Y indicate whether the first and second cards are Aces. The four probabilities follow from 48 non-Aces and 4 Aces.",
  counts20="Worked example: 20 fictional observations. Rows X=0/1 and columns Y=0/1 have counts 6,4 / 2,8. X and Y are binary indicators; these are not real student data.",
  zero_x="Boundary example: P(X=0)=0. Conditioning on X=0 is undefined; conditioning on X=1 gives probabilities 1/4 and 3/4.")
learning_pmf_notes<-c(learning_pmf_notes,exam_pmf_notes())
learning_pmf_example_choices<-function() c("Two Ace indicators"="cards","20 fictional observations"="counts20","Zero conditioning probability"="zero_x",
  stats::setNames(names(local_exam_bank$tables),vapply(local_exam_bank$tables,`[[`,character(1),"label")))
learning_pmf_caption <- function(df) {
  if(is.null(df) || nrow(df)==0L) return("Custom joint PMF: define what X, Y and their units represent before interpreting the table.")
  for(key in names(learning_pmf_notes)) {
    target<-learning_pmf_example(key)
    target<-target[order(target$x,target$y),]
    if(nrow(df)!=nrow(target))next
    a<-df[order(df$x,df$y),c("x","y","p_value")]
    if(identical(as.numeric(a$x),as.numeric(target$x)) && identical(as.numeric(a$y),as.numeric(target$y)) &&
       all(abs(a$p_value-target$p_value)<1e-12)) return(unname(learning_pmf_notes[key]))
  }
  "Custom joint PMF: define what X, Y and their units represent before interpreting the table."
}
learning_table <- function(counts=FALSE,zero=FALSE) {
  values<-if(zero) c("0","0","1/4","3/4") else if(counts) as.character(as.vector(t(learning_counts()))) else
    vapply(as.vector(t(learning_counts())),learning_fraction,character(1),d=sum(learning_counts()))
  paste0("<table class='pmf-table'><caption>",if(counts) "Frequencies (20 fictional observations)" else "Joint PMF",
    "</caption><thead><tr><th>X / Y</th><th>Y=0</th><th>Y=1</th></tr></thead><tbody>",
    "<tr><th>X=0</th><td>",values[1],"</td><td>",values[2],"</td></tr>",
    "<tr><th>X=1</th><td>",values[3],"</td><td>",values[4],"</td></tr></tbody></table>")
}
learning_field <- function(key,label,expected,kind="numeric",choices=NULL,nonnegative=TRUE) {
  list(key=key,label=label,expected=expected,kind=kind,choices=choices,nonnegative=nonnegative)
}
# Only verified local past-exam extracts are exposed to students.
# The old project library remains reachable solely by explicit internal regression tests.
learning_questions <- function(legacy,module,path="core") {
  if(learning_path(path)!="legacy") return(exam_questions(module))
  prefix<-c(joint="J",conditional="C",expectation="E",overview="O")[[module]]
  lapply(legacy,function(q) {
    q$key<-sprintf("%s%02d",prefix,q$id);q$legacy<-TRUE;q$track<-"core"
    q$stage<-if(module=="joint") "joint" else "conditional"
    q$title<-paste0("Historical regression question ",q$id)
    q
  })
}
learning_indices <- function(questions,module,path) {
  path<-learning_path(path)
  keep<-which(vapply(questions,function(q) if(path=="legacy") isTRUE(q$legacy) else identical(q$track,path),logical(1)))
  keep
}
learning_graph_examples <- function() c(list(
  bern04=list(label="CDF illustration: Bernoulli(p=0.4)",paths=c("core","legacy"),type="discrete",dist="bern",inputs=list(p_bern=.4),x=0,
    note="P(X=0)=0.6 and P(X=1)=0.4. The CDF at 0 includes X=0; compare strict and inclusive inequalities."),
  corn5=list(label="Corn: Binomial(n=5,p=0.2)",paths=c("core","legacy"),type="discrete",dist="binom",inputs=list(n=5,p=.2),x=0,
    note="Given 5 inspected plants, Y is Binomial(5,0.2). P(Y>=1)=1-F(0)=0.67232."),
  corn10=list(label="Corn: Binomial(n=10,p=0.2), mean 2",paths=c("core","legacy"),type="discrete",dist="binom",inputs=list(n=10,p=.2),x=2,
    note="With 10 independent inspected plants, the expected count is np=10*0.2=2."),
  novice=list(label="Novice: Geometric(p=0.2), failures Z",paths=c("core","legacy"),type="discrete",dist="geom",inputs=list(pg=.2),x=1,
    note="Z counts failures before success, and attempts Y=Z+1. P(Y>=3)=P(Z>=2)=1-F_Z(1)=0.64."),
  du5=list(label="Second moments: Discrete Uniform on 1,...,5",paths=c("core","legacy"),type="discrete",dist="dunifd",inputs=list(N_du=5),x=3,
    note="DU(5) has mean 3. Averaging squared outcomes gives E[Z^2]=11; variance=11-9=2."),
  tokens=list(label="Red tokens: Hypergeometric(n=5,M=8,N=20)",paths=c("core","legacy"),type="discrete",dist="hyper",inputs=list(n_hy=5,M_hy=8,N_hy=20),x=2,
    note="Draw 5 tokens without replacement from 20, including 8 red. The conditional mean is nM/N=2."),
  worker_nb=list(label="Worker: Negative Binomial(k=2,p=1/4)",paths=c("core","legacy"),type="discrete",dist="nbinom",inputs=list(r_nb=2,p_nb=.25),x=6,
    note="Y counts failures before the second success in independent trials. Its mean is k(1-p)/p=6."),
  eggs_cloudy=list(label="Cloudy eggs: Poisson(12), P(Y <= 10)",paths=c("core","legacy"),type="discrete",dist="pois",inputs=list(lambda=12),x=10,
    note="Cloudy: 2 eggs/hour for 6 hours gives lambda=12. The highlighted CDF at 10 is P(Y <= 10), about 0.3472."),
  eggs_sunny=list(label="Sunny eggs: Poisson(24), mean 24",paths=c("core","legacy"),type="discrete",dist="pois",inputs=list(lambda=24),x=24,
    note="Sunny: 4 eggs/hour for 6 hours gives lambda=24. The count mean is 24; the rate per hour is 4."),
  rain=list(label="Rain waiting time: Exponential(rate=0.5)",paths=c("preview","further","legacy"),type="continuous",dist="exp",inputs=list(rate_exp=.5),x=2,
    note="Cloudy rain model: rate=0.5 per hour, mean waiting time=2 hours. The CDF at 2 is about 0.6321."),
  normal65=list(label="Strawberries: Normal(mean=65, sd=3)",paths=c("preview","further","legacy"),type="continuous",dist="norm",inputs=list(mean_norm=65,sd_norm=3),x=70,
    note="For fertility X=3, the mean is 65 and the variance is 9 (standard deviation 3). The tail above 70 is 1-F(70), about 0.0478."),
  uniform140=list(label="Grazing: Uniform(0,140)",paths=c("preview","further","legacy"),type="continuous",dist="unif",inputs=list(a_unif=0,b_unif=140),x=50,
    note="At W=2, the assumed upper bound is 140. P(Y>50)=1-F(50)=90/140=9/14; a single point still has probability zero."),
  uniform100=list(label="Grazing: Uniform(0,100)",paths=c("further","legacy"),type="continuous",dist="unif",inputs=list(a_unif=0,b_unif=100),x=50,
    note="The optional second-moment exercise uses Uniform(0,100). The density is 1/100 and E[X^2]=10000/3."),
  normal50=list(label="Strawberries: Normal(mean=50, sd=3)",paths=c("preview","further","legacy"),type="continuous",dist="norm",inputs=list(mean_norm=50,sd_norm=3),x=50,
    note="Mean 50, variance 9, standard deviation 3. The expected squared deviation from the mean is the variance."),
  exp2=list(label="Waiting time: Exponential(rate=2)",paths=c("further","legacy"),type="continuous",dist="exp",inputs=list(rate_exp=2),x=.5,
    note="The optional second-moment illustration uses rate 2; the mean is 1/2 and E[X^2]=1/2.")),exam_graph_examples())

learning_continuous_choices <- function(path) {
  choices<-c("Uniform"="unif","Exponential"="exp","Gamma"="gamma","Normal"="norm", "Beta"="beta","Chi-Squared"="chisq","Student's t"="t","F"="f")
  switch(learning_path(path),core=character(0),preview=choices[choices %in% c("unif","exp","norm")],choices)
}
