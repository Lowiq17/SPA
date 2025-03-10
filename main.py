from passlib.context import CryptContext
import db
from flask import Flask, render_template, request, redirect, url_for, session

app = Flask(__name__)
password_ctx = CryptContext(schemes=['bcrypt']) # configuration de la bibliothèque
app.secret_key = b'1234'

horraires = {"lundi" : "08h00 - 19h30",
	    "mardi" : "08h00 - 19h30",
	    "mercredi" : "08h00 - 18h00",
	    "jeudi" : "08h00 - 19h30",
	    "vendredi" : "08h00 - 19h30"}

@app.route("/")
def home() :
    return redirect(url_for("accueil"))

@app.route("/accueil")
def accueil():
	return render_template("accueil.html")

@app.route("/compte")
def compte() :
	with db.connect() as conn :
		with conn.cursor() as cur:
			cur.execute('select fonction,id_refuge from travaille where matricule = %s',session["id"])
			travail = cur.fetchall()
			return render_template("compte.html",id = session["id"],travail = travail)

@app.route("/connexion")
def connection():
	with db.connect() as conn :
		with conn.cursor() as cur:
			if "id" not in session :
				id = request.args.get("username",None)
				mdp = request.args.get("password",None)
				if id != None and mdp != None:
					cur.execute('select mdp from employes where login_compte = %s',(id,))
					mdp_res = cur.fetchone()
					if password_ctx.verify(mdp,mdp_res.mdp) :
						cur.execute('select matricule from employes where login_compte = %s',(id,))
						session["id"] = cur.fetchone()
						return redirect(url_for("compte"))
					else :
						return render_template("connexion.html",erreur = True)
				else :
					return render_template("connexion.html",erreur = False)
			else :
				return redirect(url_for("compte"))

@app.route("/refuges")
def refuges():
	with db.connect() as conn :
		with conn.cursor() as cur:
			cur.execute('select nom,adresse from refuges')
			lst_refuges = cur.fetchall()
			cur.execute('select id_refuge from refuges')
			lst_id = cur.fetchall()
			return render_template("refuges.html",nom = lst_refuges, id = lst_id,horraires = horraires,taille = len(lst_id))

@app.route("/refuges/<string:id>")
def refuges_id(id) :
	with db.connect() as conn :
		with conn.cursor() as cur:
			cur.execute('select id_refuge from refuges')
			liste_refuges = cur.fetchall()
			for refuge in liste_refuges :
				if refuge.id_refuge == int(id) :
					cur.execute('select nom from refuges where id_refuge = %s',(id,))
					nom_ref = cur.fetchone()
					cur.execute('select adresse from refuges where id_refuge = %s',(id,))
					adresse = cur.fetchone()
					cur.execute('select num_tel from refuges where id_refuge = %s',(id,))
					num = cur.fetchone()
					cur.execute('select id_animal,image_animal, nom, age, espece, sexe, signe_distinctif from animal where id_animal in (select id_animal from refuge_animal where id_refuge = %s)',(id,))
					animaux = cur.fetchall()
					lst_animal = []
					for animal in animaux :
						cur.execute('select * from vaccins_a_faire where id_animal = %s',(animal.id_animal,))
					vaccins_a_faire = cur.fetchall()
					for vaccin in vaccins_a_faire :
						lst_animal.append(vaccin.id_animal)
					return render_template("id.html",nom_refuge=nom_ref,adresse_refuge=adresse, horraires = horraires, annimaux = animaux,num = num,vaccins = vaccins_a_faire,taille_anim = len(animaux),lst_anim = lst_animal)
			return render_template("erreur.html")

@app.route("/compte/soin")
def soin() :
	with db.connect() as conn :
		with conn.cursor() as cur:
			refuge = request.args.get("refuge",None)
			animal = request.args.get("animal",None)
			employe = request.args.get("employe",None)
			date = request.args.get("date",None)
			soin = request.args.get("type_soin",None)
			if refuge != None and animal != None and employe != None and date != "" and soin != None :
				cur.execute("INSERT INTO soin(matricule,type_soin,date_soin,id_animal) VALUES (%s,%s,%s,%s)",(employe,soin,date,animal,))
				return render_template("soin_fait.html")
			else :
				cur.execute("select id_refuge,nom from refuges")
				refuge = cur.fetchall()
				cur.execute("select id_animal,nom from animal")
				animal = cur.fetchall()
				cur.execute("select matricule,nom,prenom from employes")
				employe = cur.fetchall()
				return render_template("soin.html",refuges = refuge,animaux = animal,employes = employe)


if __name__ == '__main__':
    app.run()
