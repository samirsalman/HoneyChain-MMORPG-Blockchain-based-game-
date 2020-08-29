using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Networking;
using UnityEngine.UI;

public class LevelExit : MonoBehaviour {

    int LEVEL_SUCCESS = 4;


    [SerializeField] float LevelLoadDelay = 2f;
    [SerializeField] float LevelExitSlowMoFactor = 0.2f;

    int PRESE_TUTTE = 1;
    int NON_PRESE_TUTTE = 0;

    int allPicked = -1;


    private void CheckValidationAuthorutyToLoadLevel(string floorText, string pointText)
    {
        string url = "http://localhost:8888/levelup";
        
        
        
        StartCoroutine(SendPost(floorText, allPicked.ToString()));

        IEnumerator SendPost(string floor, string point)
        {

            WWWForm form = new WWWForm();
            form.AddField("point", point);
            form.AddField("floor", floor);

            UnityWebRequest www = UnityWebRequest.Post(url, form);
            yield return www.SendWebRequest();

            if (www.isNetworkError || www.isHttpError)
            {
                Debug.Log(www.error);
            }
            else
            {
                Debug.Log(www.downloadHandler.text.ToString());
                if (www.downloadHandler.text == "ok")
                {
                    Debug.Log("Form upload complete!");
                    StartCoroutine(LoadNextLevel());


                }
                else {
                    Debug.Log("Non hai abbastanza punti");
                }


            }
        }
        
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        string floorText = SceneManager.GetActiveScene().buildIndex.ToString();
        string pointText = FindObjectOfType<ScoreScript>().GetComponent<UnityEngine.UI.Text>().text;
        Debug.Log("sbatto");
        CheckValidationAuthorutyToLoadLevel(floorText, pointText);
        
            

        
    }

    IEnumerator LoadNextLevel()
    {
        Time.timeScale = LevelExitSlowMoFactor;
        yield return new WaitForSecondsRealtime(LevelLoadDelay);
        Time.timeScale = 1f;


        var currentSceneIndex = SceneManager.GetActiveScene().buildIndex;

        //sono arrivato alla fine del gioco
        if (currentSceneIndex == LEVEL_SUCCESS)
        {
            //call to validation autorithy to re start game from login or from level 1

            // if(responde == level 1){
            //loadl level 1
            //else{ load login page)

            
        }
        else
        {
            SceneManager.LoadScene(currentSceneIndex + 1);
        }

    }


    private void Update() {
        CountPickucpsChildren();
    }

    void CountPickucpsChildren() {
        int num = FindObjectsOfType<CoinPickup>().Length;

        if (num == 0) {
            allPicked = PRESE_TUTTE;

        }
        else {
            allPicked = NON_PRESE_TUTTE;
        }

    }

}
