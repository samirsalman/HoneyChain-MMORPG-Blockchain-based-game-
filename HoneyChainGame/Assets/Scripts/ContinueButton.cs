using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using System.Net.Http.Headers;

public class ContinueButton : MonoBehaviour {


    [SerializeField] InputField emailField;
    [SerializeField] InputField passwordField;


    string emailForDatabase = "";
	// Use this for initialization


    string getEmail() {
        return emailForDatabase;
    }

	void Start () {
        
        StartCoroutine(SendPost());

    }
    string url2 = "http://localhost:8888/user/restart";
    IEnumerator SendPost()
    {


        WWWForm form = new WWWForm();

        UnityWebRequest www = UnityWebRequest.Post(url2, form);
        yield return www.SendWebRequest();



        if (www.isNetworkError || www.isHttpError)
        {
            Debug.Log(www.error);
        }
        else
        {
            Debug.Log(www.downloadHandler.text.ToString());
            if (www.downloadHandler.text == "Cookie presente")
            {
                SceneManager.LoadScene(1);
                Destroy(gameObject);
            }

        }
    }

    // Update is called once per frame
    void Update () {
		
	}
    

    void OnButtonClick()
    {

        string emailText = emailField.text.ToString();
        string passwordText = passwordField.text.ToString();

        FindObjectOfType<GameSession>().setEmail(emailText);

        //solo per fare prove
        if (emailText == "prova") {
            SceneManager.LoadScene(1);
        }
        else {


            //fare una chiamata alla validation authoruty per convalidare

            StartCoroutine(SendPost(emailText, passwordText));

        }



    }

    string url = "http://localhost:8888/user/login";

    IEnumerator SendPost(string email,string password)
    {


        WWWForm form = new WWWForm();
        form.AddField("email", email);
        form.AddField("password", password);

        UnityWebRequest www = UnityWebRequest.Post(url, form);
        yield return www.SendWebRequest();

       

        if (www.isNetworkError || www.isHttpError)
        {
            Debug.Log(www.error);
        }
        else
        {
            Debug.Log(www.downloadHandler.text.ToString());
            if (www.downloadHandler.text == "Login effettuato con successo")
            {

                Debug.Log("Form upload complete!");

                SceneManager.LoadScene(1);
            }
            
           
        }
    }
}





